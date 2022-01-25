# Graphic for bitlocker script

```mermaid
graph TD
   Node1[Secure Boot] -->|On| Node2
   Node1[Secure Boot] -->|Off| Node3(Warning and stop)
   Node2[Tpm Ready] --> |Yes|Node4
   Node2[Tpm Ready] --> |No|Node3
   Node4[FullyDecrypted and KeyProtector] --> |Yes|Reboot(Need Reboot)
   Node4[FullyDecrypted and KeyProtector] --> |other|Node5
   Node5[EncryptionMethod] --> |None| NodeNone
   Node5[EncryptionMethod] --> |XtsAes256| Node256
   Node5[EncryptionMethod] --> |Other| NodeOther
   NodeNone{{Ready for encryption}} --> gpo(apply GPO) --> encrypt(Encrypt) --> OtherDrive(Check Other Drive)
   Node256[Algo XtsAes256 - check VolumeStatus] --> |in Progress| InProgress{{Encryption or decryption in progress}} --> Stop(Stop)
   Node256[Algo XtsAes256 - check VolumeStatus] --> |Not in Progress| NotProgress
   NotProgress[Correct Algo check Protection Status] --> |on| already{{already encrypt}} --> nothing(Nothing to do)
   NotProgress[Correct Algo check Protection Status] --> |off| suspend{{Protection is suspend}} --> resume(Resume your drive)
   NodeOther{{Not the correct algo}} --> Not256(not in XtsAes256 algo, use DisableBitlocker command)
  ```
