# Copyright 2020 The Measurement System Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("//build:defs.bzl", "to_label")

ImageImportInfo = provider(
    doc = "Information about importing container images.",
    fields = ["image_ref", "k8s_environment"],
)

def _get_image_name(image_archive_label):
    return "{repo}:{label}".format(
        repo = image_archive_label.package,
        label = image_archive_label.name.rsplit(".", 1)[0],
    )

def _k8s_import_impl(ctx):
    image_archive = ctx.file.image_archive
    runfiles = [image_archive]
    k8s_env = ctx.attr.k8s_environment
    image_name = _get_image_name(ctx.attr.image_archive.label)

    command = ""
    if k8s_env == "kind":
        command = "kind load image-archive {archive_path}".format(
            archive_path = image_archive.short_path,
        )
    elif k8s_env == "usernetes-containerd":
        usernetes_run = ctx.attr._usernetes_run.files.to_list()[0]
        runfiles.append(usernetes_run)

        command = "{usernetes_run} ctr images import {archive_path}".format(
            usernetes_run = usernetes_run.short_path,
            archive_path = image_archive.short_path,
        )
    else:
        fail("Unhandled k8s environment " + k8s_env)

    output = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(output, command, is_executable = True)

    return [
        DefaultInfo(
            executable = output,
            runfiles = ctx.runfiles(files = runfiles),
        ),
        ImageImportInfo(
            image_ref = "docker.io/" + image_name,
            k8s_environment = k8s_env,
        ),
    ]

k8s_import = rule(
    doc = "Executable that imports an image archive into a container runtime.",
    implementation = _k8s_import_impl,
    attrs = {
        "image_archive": attr.label(
            doc = "Container image archive.",
            mandatory = True,
            allow_single_file = True,
        ),
        "k8s_environment": attr.string(
            doc = "Which Kubernetes environment to use.",
            values = ["kind", "usernetes-containerd"],
            default = "kind",
        ),
        "_usernetes_run": attr.label(
            doc = "Executable tool for running commands in the Usernetes namespace.",
            default = "//build/k8s:usernetes_run",
            executable = True,
            cfg = "target",
        ),
    },
    executable = True,
    provides = [DefaultInfo, ImageImportInfo],
)

def k8s_imports(image_archives = [], k8s_environment = None):
    """Returns a list of k8s_import targets.

    Args:
        image_archives: container image archives
        k8s_environment: Kubernetes environment
    """
    import_targets = []
    for image_archive in image_archives:
        label = to_label(image_archive)
        import_name = "{label_name}_{k8s_env}_{index}".format(
            label_name = label.name,
            k8s_env = k8s_environment,
            index = len(import_targets),
        )
        import_targets.append(import_name)

        k8s_import(
            name = import_name,
            image_archive = image_archive,
            k8s_environment = k8s_environment,
        )

    return import_targets

def _k8s_apply_impl(ctx):
    if len(ctx.attr.imports) == 0:
        fail("No imports specified")

    k8s_env = ctx.attr.imports[0][ImageImportInfo].k8s_environment
    runfiles = ctx.runfiles(files = ctx.files.src)
    commands = []
    for import_target in ctx.attr.imports:
        if import_target[ImageImportInfo].k8s_environment != k8s_env:
            fail("k8s_environment must be the same for all imports")
        runfiles = runfiles.merge(import_target[DefaultInfo].default_runfiles)

    commands = [import_executable.short_path for import_executable in ctx.files.imports]
    commands.append(
        "{{ kubectl delete -f {manifest_file}; kubectl apply -f {manifest_file}; }}".format(
            manifest_file = ctx.file.src.short_path,
        ),
    )

    output = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(output, " && ".join(commands), is_executable = True)

    return DefaultInfo(executable = output, runfiles = runfiles)

_k8s_apply = rule(
    doc = "Executable that applies a Kubernetes manifest using kubectl.",
    implementation = _k8s_apply_impl,
    attrs = {
        "src": attr.label(
            doc = "A single Kubernetes manifest",
            mandatory = True,
            allow_single_file = [".yaml"],
        ),
        "imports": attr.label_list(
            doc = "k8s_import targets of images to import",
            providers = [DefaultInfo, ImageImportInfo],
            cfg = "target",
        ),
    },
    executable = True,
)

def k8s_apply(name, src, imports = [], image_archives = [], k8s_environment = None, **kwargs):
    """Executable that applies a Kubernetes manifest using kubectl.

    Args:
        src: A single Kubernetes manifest.
        imports: k8s_import targets of images to import.
        image_archives: Container image archives.
        k8s_environment: Which Kubernetes environment to use when importing
            image archives.
    """
    additional_imports = k8s_imports(image_archives, k8s_environment)

    _k8s_apply(
        name = name,
        src = src,
        imports = imports + additional_imports,
        **kwargs
    )
