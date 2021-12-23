// Copyright 2021 The Cross-Media Measurement Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package org.wfanet.measurement.common.crypto.testing

import java.nio.file.Path
import java.nio.file.Paths
import org.wfanet.measurement.common.getRuntimePath

const val KEY_ALGORITHM = "EC"

/**
 * For some tests, we used a fixed certificate server.*. All the other certificates are generated by
 * bazel and are likely cached by bazel.
 */
private val FIXED_TESTDATA_DIR_PATH: Path =
  getRuntimePath(
    Paths.get(
      "wfa_common_jvm",
      "src",
      "main",
      "kotlin",
      "org",
      "wfanet",
      "measurement",
      "common",
      "crypto",
      "testing",
      "testdata"
    )
  )!!

val FIXED_SERVER_CERT_PEM_FILE = FIXED_TESTDATA_DIR_PATH.resolve("server.pem").toFile()
val FIXED_SERVER_KEY_FILE = FIXED_TESTDATA_DIR_PATH.resolve("server.key").toFile()
val FIXED_SERVER_CERT_DER_FILE = FIXED_TESTDATA_DIR_PATH.resolve("server-cert.der").toFile()
val FIXED_SERVER_KEY_DER_FILE = FIXED_TESTDATA_DIR_PATH.resolve("server-key.der").toFile()
val FIXED_CA_CERT_PEM_FILE = FIXED_TESTDATA_DIR_PATH.resolve("ca.pem").toFile()

val FIXED_ENCRYPTION_PRIVATE_KEYSET = FIXED_TESTDATA_DIR_PATH.resolve("enc-private.tink").toFile()
val FIXED_ENCRYPTION_PUBLIC_KEYSET = FIXED_TESTDATA_DIR_PATH.resolve("enc-public.tink").toFile()