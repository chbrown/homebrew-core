class Libetonyek < Formula
  desc "Interpret and import Apple Keynote presentations"
  homepage "https://wiki.documentfoundation.org/DLP/Libraries/libetonyek"
  url "https://dev-www.libreoffice.org/src/libetonyek/libetonyek-0.1.10.tar.xz"
  sha256 "b430435a6e8487888b761dc848b7981626eb814884963ffe25eb26a139301e9a"

  livecheck do
    url "https://dev-www.libreoffice.org/src/"
    regex(/href=["']?libetonyek[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    rebuild 1
    sha256 arm64_big_sur: "ebe89d1aa295f4581376bf47a37884f02a1f4da97568a7968baaeba69421de45"
    sha256 big_sur:       "e08c335554a42a123047a08050f1599eed8ac43e45bc264d2ebdbab181a6a64c"
    sha256 catalina:      "fe426f3577057ac3a73b9527b01124e5f916872b505f12e8224674d72a700c5b"
    sha256 mojave:        "b51d5847f87fba35e67703d248f0552a4e03eb6fc4e35ba5a180f41fec68fdeb"
    sha256 high_sierra:   "d86fef6a245db1b767d8965362eae4782af35b2c2b14e819ae7d436790f909cd"
  end

  depends_on "boost" => :build
  depends_on "glm" => :build
  depends_on "mdds" => :build
  depends_on "pkg-config" => :build
  depends_on "librevenge"

  uses_from_macos "libxml2"

  resource "liblangtag" do
    url "https://bitbucket.org/tagoh/liblangtag/downloads/liblangtag-0.6.3.tar.bz2"
    sha256 "1f12a20a02ec3a8d22e54dedb8b683a43c9c160bda1ba337bf1060607ae733bd"
  end

  def install
    resource("liblangtag").stage do
      system "./configure", "--prefix=#{libexec}", "--enable-modules=no"
      system "make"
      system "make", "install"
    end

    ENV["LANGTAG_CFLAGS"] = "-I#{libexec}/include"
    ENV["LANGTAG_LIBS"] = "-L#{libexec}/lib -llangtag -lxml2"
    system "./configure", "--without-docs",
                          "--disable-dependency-tracking",
                          "--enable-static=no",
                          "--disable-werror",
                          "--disable-tests",
                          "--prefix=#{prefix}",
                          "--with-mdds=1.5"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <libetonyek/EtonyekDocument.h>
      int main() {
        return libetonyek::EtonyekDocument::RESULT_OK;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-o", "test",
                    "-I#{Formula["librevenge"].include}/librevenge-0.0",
                    "-I#{include}/libetonyek-0.1",
                    "-L#{Formula["librevenge"].lib}",
                    "-L#{lib}",
                    "-lrevenge-0.0",
                    "-letonyek-0.1"
    system "./test"
  end
end
