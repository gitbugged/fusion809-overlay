# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils multilib

MY_PV="1.3.8-test1"
MY_P=$PN-${MY_PV}
DESCRIPTION="The Open Racing Car Simulator"
HOMEPAGE="http://torcs.sourceforge.net/"
SRC_URI="mirror://sourceforge/torcs/${MY_P}.tar.bz2"

LICENSE="GPL-2 FreeArt"
SLOT="0"
IUSE=""

RDEPEND="media-libs/freealut
	media-libs/freeglut
	media-libs/libpng:0
	media-libs/libvorbis:=
	media-libs/openal
	>=media-libs/plib-1.8.5
	sys-libs/zlib:0=
	virtual/opengl
	virtual/glu
	x11-libs/libX11
	x11-libs/libXrandr"
DEPEND="${RDEPEND}
	x11-proto/xf86vidmodeproto"

PATCHES=(
	"${FILESDIR}"/${MY_P}-no-automake.patch
	"${FILESDIR}"/${PN}-as-needed.patch
	"${FILESDIR}"/${PN}-flags.patch
	"${FILESDIR}"/${PN}-format.patch
	"${FILESDIR}"/${PN}-noXmuXt.patch
)

S=${WORKDIR}/${MY_P}

src_prepare() {
	default

	eautoreconf
	ecvs_clean
}

src_configure() {
	addpredict $(echo /dev/snd/controlC? | sed 's/ /:/g')
	[[ -e /dev/dsp ]] && addpredict /dev/dsp
	econf \
		--datadir=/usr/share \
		--x-libraries=/usr/$(get_libdir) \
		--enable-xrandr
	# The following line fixes bug 594670 (https://bugs.gentoo.org/show_bug.cgi?id=594670)
    sed -i -e 's/#include <cmath>/#include <math.h>/g' src/drivers/olethros/geometry.cpp
}

src_compile() {
	# So ugly... patches welcome.
	emake -j1
}

src_install() {
	emake -j1 DESTDIR="${D}" install datainstall
	newicon Ticon.png ${PN}.png
	make_desktop_entry ${PN} TORCS
	dodoc README doc/history/history.txt
	doman doc/man/*.6
	dodoc -r doc/faq/faq.html doc/tutorials doc/userman
}
