# private-join-and-compute library used in the C++ crypto primitive.
#
# @com_google_private_join_and_compute
# See https://github.com/google/private-join-and-compute/

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def private_join_and_compute_repo(commit, sha256):
    http_archive(
        name = "com_google_private_join_and_compute",
        sha256 = sha256,
        strip_prefix = "private-join-and-compute-" + commit,
        urls = [
            "https://github.com/google/private-join-and-compute/archive/%s.zip" % commit,
        ],
    )

    _deps()

def _deps():
    if not native.existing_rule("com_github_glog_glog"):
        http_archive(
            name = "com_github_glog_glog",
            sha256 = "f28359aeba12f30d73d9e4711ef356dc842886968112162bc73002645139c39c",
            strip_prefix = "glog-0.4.0",
            urls = ["https://github.com/google/glog/archive/v0.4.0.tar.gz"],
        )

    # Needed for @com_github_glog_glog
    if not native.existing_rule("com_github_gflags_gflags"):
        http_archive(
            name = "com_github_gflags_gflags",
            sha256 = "34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf",
            strip_prefix = "gflags-2.2.2",
            urls = [
                "https://mirror.bazel.build/github.com/gflags/gflags/archive/v2.2.2.tar.gz",
                "https://github.com/gflags/gflags/archive/v2.2.2.tar.gz",
            ],
        )
