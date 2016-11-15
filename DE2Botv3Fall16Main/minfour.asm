LOADI 1
STORE index
MOVR r2, r4

CMP r5, r2
JPOS prt1
MOVR r2, r5
LOADI 2
STORE index


prt1:
CMP r6, r2
JPOS prt2
MOVR r2, r6
LOADI 3
STORE index

prt2:
CMP r7, r2
JPOS prt3
MOVR r2, r7
LOADI 4
STORE index

prt3:
LOAD index
MOVR r1, r0

return
