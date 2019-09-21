{ stdenv
, fetchurl
, ncurses
, libuuid
, libiconv # opt
, enableJpeg ? false, libjpeg ? null
, enableZlib ? false, zlib ? null
, enableNtfs ? false, ntfs3g ? null
, enableExtFs ? false, e2fsprogs ? null
# Currently broken in 7.1
#, enableEwf ? false, libewf ? null
, enableQt ? false, qtbase ? null, qttools ? null, qwt ? null
}:

assert enableJpeg -> libjpeg != null;
assert enableZlib -> zlib != null;
assert enableNtfs -> ntfs3g != null;
assert enableExtFs -> e2fsprogs != null;
#assert enableEwf -> libewf != null;
assert enableQt -> qtbase != null;
assert enableQt -> qttools != null;

stdenv.mkDerivation rec {
  pname = "testdisk";
  version = "7.1";
  src = fetchurl {
    url = "https://www.cgsecurity.org/testdisk-${version}.tar.bz2";
    sha256 = "0ba4wfz2qrf60vwvb1qsq9l6j0pgg81qgf7fh22siaz649mkpfq0";
  };

  buildInputs = [
    ncurses
    libuuid
  ]
  ++ stdenv.lib.optional enableJpeg libjpeg
  ++ stdenv.lib.optional enableZlib zlib
  ++ stdenv.lib.optional enableNtfs ntfs3g
  ++ stdenv.lib.optional enableExtFs e2fsprogs
#  ++ stdenv.lib.optional enableEwf libewf
++ stdenv.lib.optional enableQt [ qtbase qttools qwt ];

  QTGUI_LIBS="${qwt}/lib";

  meta = with stdenv.lib; {
    homepage = https://www.cgsecurity.org/wiki/Main_Page;
    downloadPage = https://www.cgsecurity.org/wiki/TestDisk_Download;
    description = "Data recovery utilities";
    longDescription = ''
      TestDisk is a powerful free data recovery software. It was primarily
      designed to help recover lost partitions and/or make non-booting disks
      bootable again when these symptoms are caused by faulty software: certain
      types of viruses or human error (such as accidentally deleting a
      Partition Table).

      PhotoRec is a file data recovery software designed to recover lost files
      including video, documents and archives from hard disks, CD-ROMs, and
      lost pictures (thus the Photo Recovery name) from digital camera memory.
      PhotoRec ignores the file system and goes after the underlying data, so
      it will still work even if your media's file system has been severely
      damaged or reformatted.
    '';
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.all;
    maintainers = with maintainers; [ fgaz eelco ];
  };
}

