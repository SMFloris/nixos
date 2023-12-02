#!/usr/bin/env python
import hashlib
import sys
import logging

logging.basicConfig(filename="/tmp/fccunlocker.log", level=logging.INFO)
logging.info("WORKS!");

salt = {
        '8086:7560': b"\xbb\x23\xbe\x7f",
        '8086:4d75': b"\x74\xde\xbb\xa9"
        # ???: \xcc\xa6\x1d\xdf"
}

devid = sys.argv[0].split('/')[-1]
dbusd = sys.argv[1]
ctldevs = sys.argv[2:]

# FIXME
ctldev='wwan0at0'

logging.info(devid);
logging.info(dbusd);
logging.info(ctldevs);
logging.info(ctldev);
logging.info("START");

def read_to_cr(c):
    data = c.readline()
    nocr = data.strip(b'\r\n')
    if nocr == b'':
        return read_to_cr(c)
    logging.info(f'response from modem: {nocr.decode("utf-8")}')
    if nocr == b'ERROR':
        logging.info("READ ERROR")
        sys.exit(1)
    return nocr

def query_modem(c, query):
    logging.info(f'query modem: {query.decode("utf-8")}')
    c.write(query)
    res = read_to_cr(c)
    if res != b'OK':
        read_to_cr(c)
    return res

with open(f'/dev/{ctldev}', 'r+b', buffering=0) as c:
    locked = query_modem(c, b'at+gtfcclockstate\r')
    if locked == b'1':
        logging.info(f'LOCKED FRSM')
        sys.exit(0)

    # > at+gtfcclockgen
    # < 0x12345678 (a challenge, some eight-digit hex string)
    challenge = query_modem(c, b'at+gtfcclockgen\r')

    challenge = int(challenge, 16).to_bytes(4, byteorder='little')
    to_hash = challenge + salt[devid]

    m = hashlib.sha256()
    m.update(to_hash)
    res = str(int.from_bytes(m.digest()[:4], byteorder='little'))

    #> at+gtfcclockver=1927859199
    #< OK
    query_modem(c, b'at+gtfcclockver=' + res.encode('utf-8') + b'\r')
    #> at+gtfcclockmodeunlock
    #< OK
    query_modem(c, b'at+gtfcclockmodeunlock\r')
    #> at+cfun=1
    #< OK
    query_modem(c, b'at+cfun=1\r')
    #> at+gtfcclockstate
    #< 1
    #<
    #< OK
    locked = query_modem(c, b'at+gtfcclockstate\r')
    if locked == b'1':
        logging.info(f'LOCKED FRSM 2')
        sys.exit(0)

logging.info("FINISH")
sys.exit(1)
