
lestrade: standalone server, 128G RAM, ASM on SSD, Oracle 21c
client was sqlrun VBox VM on japp

ora192rac: 2-node RAC, 16g RAM, ASM on SSD, Oracle 19c
client was swingbench-cli-03 VM on baynes
all tests were run against node 2

Neither client was particularly stressed by these tests.

ora192rac nodes are underprovisioned, but they are not normally used for performance testing. 
They are used for testing RAC features and for testing Oracle 19c.

lestrade is a standalone server with 128G RAM and ASM on SSD. It is used for performance testing.





