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

package org.wfanet.measurement.common.crypto.tink

import com.google.crypto.tink.Aead
import com.google.crypto.tink.KmsClients
import org.wfanet.measurement.common.crypto.KeyStorageProvider
import org.wfanet.measurement.common.crypto.PrivateKeyStore as CryptoPrivateKeyStore
import org.wfanet.measurement.storage.StorageClient
import org.wfanet.measurement.storage.Store

class TinkKeyStorageProvider : KeyStorageProvider<TinkPrivateKeyHandle> {
  override fun makeKmsStorageClient(storageClient: StorageClient, keyUri: String): StorageClient {
    return KmsStorageClient(storageClient, getKmsAead(keyUri))
  }

  override fun makeKmsPrivateKeyStore(
    store: Store<String>,
    keyUri: String
  ): CryptoPrivateKeyStore<TinkPrivateKeyHandle> {
    return PrivateKeyStore(store, getKmsAead(keyUri))
  }
}

private fun getKmsAead(keyUri: String): Aead {
  return KmsClients.get(keyUri).getAead(keyUri)
}