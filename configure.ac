AC_PREREQ([2.52])

dnl AC_INIT([gst-openmax], m4_esyscmd([build-aux/git-version-gen]),
AC_INIT([gst-openmax], [GST_DM81XX_00_07_00_00], [https://gstreamer.ti.com/gf/project/gstreamer_ti/forum/])

AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([-Wall -Wno-portability])
AC_CONFIG_HEADERS([config.h])

dnl versions of GStreamer
GST_MAJORMINOR=0.10
GST_REQUIRED=0.10.0

dnl AM_MAINTAINER_MODE provides the option to enable maintainer mode
AM_MAINTAINER_MODE

dnl check for tools
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_INSTALL
AC_PROG_LIBTOOL

PKG_CHECK_MODULES([CHECK], [check], HAVE_CHECK=yes, HAVE_CHECK=no)

dnl Keep correct libtool macros in-tree.
AC_CONFIG_MACRO_DIR([m4])

dnl initialize GStreamer macros
AG_GST_INIT

dnl define an ERROR_CFLAGS Makefile variable
dnl AG_GST_SET_ERROR_CFLAGS($GST_CVS)

dnl add GStreamer arguments
AG_GST_ARG_DEBUG
AG_GST_ARG_PROFILING
AG_GST_ARG_VALGRIND
AG_GST_ARG_GCOV

AG_GST_ARG_WITH_PKG_CONFIG_PATH
AG_GST_ARG_WITH_PACKAGE_NAME
AG_GST_ARG_WITH_PACKAGE_ORIGIN

dnl ** checks **

dnl Check for OMX
PKG_CHECK_MODULES([OMX], [libtiomx])

dnl Check for GLib
PKG_CHECK_MODULES([GTHREAD], [gthread-2.0])

dnl Check for GStreamer
AG_GST_CHECK_GST($GST_MAJORMINOR, [$GST_REQUIRED])
AG_GST_CHECK_GST_BASE($GST_MAJORMINOR, [$GST_REQUIRED])
AG_GST_CHECK_GST_CHECK($GST_MAJORMINOR, [$GST_REQUIRED], [no])

dnl ** finalize ***

dnl set license and copyright notice
GST_LICENSE="LGPL"
AC_DEFINE_UNQUOTED(GST_LICENSE, "$GST_LICENSE", [GStreamer license])
AC_SUBST(GST_LICENSE)

dnl set GStreamer plug-in dir
AG_GST_SET_PLUGINDIR

dnl GST_OPTION_CFLAGS
if test "x$USE_DEBUG" = xyes; then
   PROFILE_CFLAGS="-g"
fi
AC_SUBST(PROFILE_CFLAGS)

dnl XXX temporarily disabled deprecated checks because gst_element_class_set_details()
dnl was deprecated..  this is only a temporary solution
dnl DEPRECATED_CFLAGS="-DGST_DISABLE_DEPRECATED"
dnl AC_SUBST(DEPRECATED_CFLAGS)

dnl every flag in GST_OPTION_CFLAGS can be overridden at make time
GST_OPTION_CFLAGS="\$(ERROR_CFLAGS) \$(DEBUG_CFLAGS) \$(PROFILE_CFLAGS) \$(GCOV_CFLAGS) \$(OPT_CFLAGS) \$(DEPRECATED_CFLAGS)"
AC_SUBST(GST_OPTION_CFLAGS)

dnl our libraries need to be versioned correctly
AC_SUBST(GST_LT_LDFLAGS)

dnl FIXME: do we want to rename to GST_ALL_* ?
dnl prefer internal headers to already installed ones
dnl also add builddir include for enumtypes and marshal
dnl add GST_OPTION_CFLAGS, but overridable
GST_CFLAGS="-I\$(top_srcdir)/gst-libs -I\$(top_builddir)/gst-libs $GST_CFLAGS \$(GST_OPTION_CFLAGS)"
AC_SUBST(GST_CFLAGS)
AC_SUBST(GST_LIBS)

dnl LDFLAGS really should only contain flags, not libs - they get added before
dnl whatevertarget_LIBS and -L flags here affect the rest of the linking
GST_ALL_LDFLAGS="-no-undefined"
AC_SUBST(GST_ALL_LDFLAGS)

dnl this really should only contain flags, not libs - they get added before
dnl whatevertarget_LIBS and -L flags here affect the rest of the linking
GST_PLUGIN_LDFLAGS="-module -avoid-version -export-symbols-regex '^[_]*gst_plugin_desc\$\$' $GST_ALL_LDFLAGS"
AC_SUBST(GST_PLUGIN_LDFLAGS)


dnl Check for the GStreamer plugins directory
AC_ARG_VAR([GST_PLUGIN_PATH], [installation path for the gstreamer-openmax plugin elements for GStreamer 0.10])
AC_MSG_CHECKING([for GStreamer plugins directory])
if test -d "$GST_PLUGIN_PATH"; then
	GST_PLUGINS_DIR="$GST_PLUGIN_PATH"
else
	GST_PLUGINS_DIR=`$PKG_CONFIG gstreamer-0.10 --variable pluginsdir`
	if test -z "$GST_PLUGINS_DIR"; then
		GST_PLUGINS_DIR="\$(libdir)/gstreamer-$GST_PKG_VERSION"
	fi
fi
AC_MSG_RESULT([$GST_PLUGINS_DIR])
plugindir="$GST_PLUGINS_DIR"
AC_SUBST(plugindir)

SHAVE_INIT
AC_CONFIG_FILES([shave shave-libtool])

AC_CONFIG_FILES([Makefile \
		 omx/Makefile \
		 util/Makefile \
		 m4/Makefile])

AC_OUTPUT
