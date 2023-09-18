
# run strace on sqlrun test

strace is being used to find how much time is being spent to write to sqltrace files

## ./strace-TRC-OVRHD.sh

Start sqlrun at the client

on vm sqlrun, there is a modified version of `lib/Sqlrun.pm` that will pause the run just after child connections are made.

it will pause each child, so this is easiest if running only 1 child (`--max-sessions 1`).

## log files

see files in the logs directory for a listing of open file handles per process

this is how we know that the trace files are on FD 11 and 12

## get the write times for .tr[cm] files

grep -E 'write\([11|12]' trace/pid-6237.strace | awk '{ print  }' | tr -d '[<>]'| ./sum.py


## Example of 20 minute run with 10046

sqlrun was run for a single session for 20 minutes, with sqltrace enabled at level 12.

these is the same tests are performed in ../, but with just one session.

strace was used to determine how much time was spent in writing trace files

to understand the command line, it would be helpful to see a couple of the relevant lines from the strace file:

```text
6237  1695062411.443254 write(11, "=====================\n", 22) = 22 <0.000006>
6237  1695062411.443272 write(12, "80jx0y1$kxstsql*kxst.czO3M\n", 27) = 27 <0.000005>
```

The time required for the call is the last part of the line, enclosed in `<>`.

Now to sum up the write times

```text
$  grep -E 'write\([11|12]' trace/pid-6237.strace | awk '{ print $NF  }' | tr -d '[<>]'| sum.py
12.496772999997965
```

From a 20 minute session of select and inserts, with no think time between iterations, there was only 12.5 seconds of time spent writing trace files.

Here is a complete breakdown of the strace:

```text
$  strace-breakdown.pl  trace/pid-6237.strace

  Total Counted Time: 1165.91173999967
  Total Elapsed Time: 1218.10785794258
Unaccounted for Time: 52.1961179429084

                      Call       Count          Elapsed                Min             Max          Avg ms
                    gettid           2           0.000006         0.000003        0.000003        0.000003
                       brk           2           0.000008         0.000004        0.000004        0.000004
                 getrlimit           4           0.000012         0.000003        0.000003        0.000003
                  mprotect           2           0.000013         0.000006        0.000007        0.000007
                     uname           3           0.000015         0.000004        0.000006        0.000005
                setsockopt           5           0.000019         0.000003        0.000005        0.000004
                getsockopt           6           0.000021         0.000003        0.000005        0.000004
                 epoll_ctl           7           0.000025         0.000003        0.000005        0.000004
                     chown           8           0.000054         0.000005        0.000010        0.000007
              rt_sigaction          22           0.000074         0.000003        0.000011        0.000003
                     fcntl          22           0.000074         0.000003        0.000007        0.000003
            rt_sigprocmask          20           0.000077         0.000003        0.000020        0.000004
                     fstat           1           0.000089         0.000089        0.000089        0.000089
                   geteuid          42           0.000126         0.000003        0.000003        0.000003
                     lstat          21           0.000135         0.000003        0.000031        0.000006
                      open          34           0.000174         0.000003        0.000014        0.000005
                      stat          56           0.000207         0.000003        0.000008        0.000004
                     close          32           0.000378         0.000003        0.000068        0.000012
                    semctl          15           0.001109         0.000015        0.000260        0.000074
                    munmap          24           0.001127         0.000008        0.000099        0.000047
                      mmap         104           0.001809         0.000005        0.000156        0.000017
                     shmdt           5           0.002062         0.000007        0.001878        0.000412
                   recvmsg        3220           0.021909         0.000003        0.000257        0.000007
                   sendmsg        2529           0.090821         0.000008        0.000918        0.000036
                epoll_wait        2035           0.167436         0.000003        0.001321        0.000082
                     ioctl         534           0.359921         0.000009        0.065599        0.000674
                 getrusage      108898           0.726873         0.000002        0.006818        0.000007
                     semop       13702           0.877790         0.000003        0.001226        0.000064
                     lseek      969033           5.195529         0.000002        0.007086        0.000005
-->>                 write     1991736          12.496773         0.000002        0.010083        0.000006
                semtimedop       14161          15.281141         0.000004        0.109176        0.001079
                      read       53844        1130.685933         0.000003       20.464132        0.020999
```

The write time of 12.496773 seconds matches with the manual extract with awk of the write times from the strace file.






