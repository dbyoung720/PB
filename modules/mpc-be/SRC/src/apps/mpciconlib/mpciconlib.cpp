/*
 * (C) 2008-2020 see Authors.txt
 *
 * This file is part of MPC-BE.
 *
 * MPC-BE is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * MPC-BE is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <Windows.h>
#include <tchar.h>
#include "resource.h"

extern "C" __declspec(dllexport) int get_icon_index(LPCWSTR ext)
{
	int iconindex = IDI_NONE;

	// icons by type
	if (_wcsicmp(ext, L":video") == 0) {
		iconindex = IDI_DEFAULT_VIDEO_ICON;
	} else if (_wcsicmp(ext, L":audio") == 0) {
		iconindex = IDI_DEFAULT_AUDIO_ICON;
	} else if (_wcsicmp(ext, L":playlist") == 0) {
		iconindex = IDI_PLAYLIST_ICON;
	}
	// icons by extension
	else if (_wcsicmp(ext, L".3g2") == 0) {
		iconindex = IDI_3G2_ICON;
	} else if (_wcsicmp(ext, L".3ga") == 0
			|| _wcsicmp(ext, L".3gp") == 0) {
		iconindex = IDI_3GP_ICON;
	} else if (_wcsicmp(ext, L".3gp2") == 0) {
		iconindex = IDI_3GP2_ICON;
	} else if (_wcsicmp(ext, L".3gpp") == 0) {
		iconindex = IDI_3GPP_ICON;
	} else if (_wcsicmp(ext, L".aac") == 0) {
		iconindex = IDI_AAC_ICON;
	} else if (_wcsicmp(ext, L".ac3") == 0) {
		iconindex = IDI_AC3_ICON;
	} else if (_wcsicmp(ext, L".aif") == 0) {
		iconindex = IDI_AIF_ICON;
	} else if (_wcsicmp(ext, L".aifc") == 0) {
		iconindex = IDI_AIFC_ICON;
	} else if (_wcsicmp(ext, L".aiff") == 0) {
		iconindex = IDI_AIFF_ICON;
	} else if (_wcsicmp(ext, L".alac") == 0) {
		iconindex = IDI_ALAC_ICON;
	} else if (_wcsicmp(ext, L".amr") == 0
			|| _wcsicmp(ext, L".awb") == 0) {
		iconindex = IDI_AMR_ICON;
	} else if (_wcsicmp(ext, L".amv") == 0) {
		iconindex = IDI_AMV_ICON;
	} else if (_wcsicmp(ext, L".aob") == 0) {
		iconindex = IDI_AOB_ICON;
	} else if (_wcsicmp(ext, L".ape") == 0) {
		iconindex = IDI_APE_ICON;
	} else if (_wcsicmp(ext, L".apl") == 0) {
		iconindex = IDI_APL_ICON;
	} else if (_wcsicmp(ext, L".asf") == 0) {
		iconindex = IDI_ASF_ICON;
	} else if (_wcsicmp(ext, L".au") == 0) {
		iconindex = IDI_AU_ICON;
	} else if (_wcsicmp(ext, L".avi") == 0) {
		iconindex = IDI_AVI_ICON;
	} else if (_wcsicmp(ext, L".bik") == 0) {
		iconindex = IDI_BIK_ICON;
	} else if (_wcsicmp(ext, L".cda") == 0) {
		iconindex = IDI_CDA_ICON;
	} else if (_wcsicmp(ext, L".divx") == 0) {
		iconindex = IDI_DIVX_ICON;
	} else if (_wcsicmp(ext, L".dsa") == 0) {
		iconindex = IDI_DSA_ICON;
	} else if (_wcsicmp(ext, L".dsm") == 0) {
		iconindex = IDI_DSM_ICON;
	} else if (_wcsicmp(ext, L".dss") == 0) {
		iconindex = IDI_DSS_ICON;
	} else if (_wcsicmp(ext, L".dsv") == 0) {
		iconindex = IDI_DSV_ICON;
	} else if (_wcsicmp(ext, L".dts") == 0
			|| _wcsicmp(ext, L".dtshd") == 0) {
		iconindex = IDI_DTS_ICON;
	} else if (_wcsicmp(ext, L".evo") == 0) {
		iconindex = IDI_EVO_ICON;
	} else if (_wcsicmp(ext, L".f4v") == 0) {
		iconindex = IDI_F4V_ICON;
	} else if (_wcsicmp(ext, L".flac") == 0) {
		iconindex = IDI_FLAC_ICON;
	} else if (_wcsicmp(ext, L".flc") == 0) {
		iconindex = IDI_FLC_ICON;
	} else if (_wcsicmp(ext, L".fli") == 0) {
		iconindex = IDI_FLI_ICON;
	} else if (_wcsicmp(ext, L".flic") == 0) {
		iconindex = IDI_FLIC_ICON;
	} else if (_wcsicmp(ext, L".flv") == 0
			|| _wcsicmp(ext, L".iflv") == 0) {
		iconindex = IDI_FLV_ICON;
	} else if (_wcsicmp(ext, L".hdmov") == 0) {
		iconindex = IDI_HDMOV_ICON;
	} else if (_wcsicmp(ext, L".ifo") == 0) {
		iconindex = IDI_IFO_ICON;
	} else if (_wcsicmp(ext, L".ivf") == 0) {
		iconindex = IDI_IVF_ICON;
	} else if (_wcsicmp(ext, L".m1a") == 0) {
		iconindex = IDI_M1A_ICON;
	} else if (_wcsicmp(ext, L".m1v") == 0) {
		iconindex = IDI_M1V_ICON;
	} else if (_wcsicmp(ext, L".m2a") == 0) {
		iconindex = IDI_M2A_ICON;
	} else if (_wcsicmp(ext, L".m2p") == 0) {
		iconindex = IDI_M2P_ICON;
	} else if (_wcsicmp(ext, L".m2t") == 0
			|| _wcsicmp(ext, L".ssif") == 0) {
		iconindex = IDI_M2T_ICON;
	} else if (_wcsicmp(ext, L".m2ts") == 0) {
		iconindex = IDI_M2TS_ICON;
	} else if (_wcsicmp(ext, L".m2v") == 0) {
		iconindex = IDI_M2V_ICON;
	} else if (_wcsicmp(ext, L".m4a") == 0) {
		iconindex = IDI_M4A_ICON;
	} else if (_wcsicmp(ext, L".m4b") == 0) {
		iconindex = IDI_M4B_ICON;
	} else if (_wcsicmp(ext, L".m4v") == 0) {
		iconindex = IDI_M4V_ICON;
	} else if (_wcsicmp(ext, L".mid") == 0) {
		iconindex = IDI_MID_ICON;
	} else if (_wcsicmp(ext, L".midi") == 0) {
		iconindex = IDI_MIDI_ICON;
	} else if (_wcsicmp(ext, L".mka") == 0) {
		iconindex = IDI_MKA_ICON;
	} else if (_wcsicmp(ext, L".mkv") == 0
			|| _wcsicmp(ext, L".mk3d") == 0) {
		iconindex = IDI_MKV_ICON;
	} else if (_wcsicmp(ext, L".mlp") == 0) {
		iconindex = IDI_MLP_ICON;
	} else if (_wcsicmp(ext, L".mov") == 0
			|| _wcsicmp(ext, L".qt") == 0) {
		iconindex = IDI_MOV_ICON;
	} else if (_wcsicmp(ext, L".mp2") == 0) {
		iconindex = IDI_MP2_ICON;
	} else if (_wcsicmp(ext, L".mp2v") == 0) {
		iconindex = IDI_MP2V_ICON;
	} else if (_wcsicmp(ext, L".mp3") == 0) {
		iconindex = IDI_MP3_ICON;
	} else if (_wcsicmp(ext, L".mp4") == 0) {
		iconindex = IDI_MP4_ICON;
	} else if (_wcsicmp(ext, L".mp4v") == 0) {
		iconindex = IDI_MP4V_ICON;
	} else if (_wcsicmp(ext, L".mpa") == 0) {
		iconindex = IDI_MPA_ICON;
	} else if (_wcsicmp(ext, L".mpc") == 0) {
		iconindex = IDI_MPC_ICON;
	} else if (_wcsicmp(ext, L".mpe") == 0) {
		iconindex = IDI_MPE_ICON;
	} else if (_wcsicmp(ext, L".mpeg") == 0) {
		iconindex = IDI_MPEG_ICON;
	} else if (_wcsicmp(ext, L".mpg") == 0
			|| _wcsicmp(ext, L".pss") == 0) {
		iconindex = IDI_MPG_ICON;
	} else if (_wcsicmp(ext, L".mpv2") == 0) {
		iconindex = IDI_MPV2_ICON;
	} else if (_wcsicmp(ext, L".mpv4") == 0) {
		iconindex = IDI_MPV4_ICON;
	} else if (_wcsicmp(ext, L".mts") == 0) {
		iconindex = IDI_MTS_ICON;
	} else if (_wcsicmp(ext, L".ofr") == 0) {
		iconindex = IDI_OFR_ICON;
	} else if (_wcsicmp(ext, L".ofs") == 0) {
		iconindex = IDI_OFS_ICON;
	} else if (_wcsicmp(ext, L".oga") == 0) {
		iconindex = IDI_OGA_ICON;
	} else if (_wcsicmp(ext, L".ogg") == 0) {
		iconindex = IDI_OGG_ICON;
	} else if (_wcsicmp(ext, L".ogm") == 0) {
		iconindex = IDI_OGM_ICON;
	} else if (_wcsicmp(ext, L".ogv") == 0) {
		iconindex = IDI_OGV_ICON;
//	} else if (_wcsicmp(ext, L".plc") == 0) {
//		iconindex = IDI_PLC_ICON;
	} else if (_wcsicmp(ext, L".pva") == 0) {
		iconindex = IDI_PVA_ICON;
	} else if (_wcsicmp(ext, L".ra") == 0) {
		iconindex = IDI_RA_ICON;
	} else if (_wcsicmp(ext, L".ram") == 0) {
		iconindex = IDI_RAM_ICON;
	} else if (_wcsicmp(ext, L".rat") == 0
			|| _wcsicmp(ext, L".ratdvd") == 0) {
		iconindex = IDI_RATDVD_ICON;
	} else if (_wcsicmp(ext, L".rec") == 0) {
		iconindex = IDI_REC_ICON;
	} else if (_wcsicmp(ext, L".rm") == 0
			|| _wcsicmp(ext, L".rmvb") == 0) {
		iconindex = IDI_RM_ICON;
	} else if (_wcsicmp(ext, L".rmi") == 0) {
		iconindex = IDI_RMI_ICON;
	} else if (_wcsicmp(ext, L".rmm") == 0) {
		iconindex = IDI_RMM_ICON;
	} else if (_wcsicmp(ext, L".roq") == 0) {
		iconindex = IDI_ROQ_ICON;
	} else if (_wcsicmp(ext, L".rp") == 0) {
		iconindex = IDI_RP_ICON;
	} else if (_wcsicmp(ext, L".rt") == 0) {
		iconindex = IDI_RT_ICON;
	} else if (_wcsicmp(ext, L".smil") == 0) {
		iconindex = IDI_SMIL_ICON;
	} else if (_wcsicmp(ext, L".smk") == 0) {
		iconindex = IDI_SMK_ICON;
	} else if (_wcsicmp(ext, L".snd") == 0) {
		iconindex = IDI_SND_ICON;
	} else if (_wcsicmp(ext, L".swf") == 0) {
		iconindex = IDI_SWF_ICON;
	} else if (_wcsicmp(ext, L".tak") == 0) {
		iconindex = IDI_TAK_ICON;
	} else if (_wcsicmp(ext, L".tp") == 0) {
		iconindex = IDI_TP_ICON;
	} else if (_wcsicmp(ext, L".trp") == 0) {
		iconindex = IDI_TRP_ICON;
	} else if (_wcsicmp(ext, L".ts") == 0) {
		iconindex = IDI_TS_ICON;
	} else if (_wcsicmp(ext, L".tta") == 0) {
		iconindex = IDI_TTA_ICON;
	} else if (_wcsicmp(ext, L".vob") == 0) {
		iconindex = IDI_VOB_ICON;
//	} else if (_wcsicmp(ext, L".vp6") == 0) {
//		iconindex = IDI_VP6_ICON;
	} else if (_wcsicmp(ext, L".wav") == 0) {
		iconindex = IDI_WAV_ICON;
//	} else if (_wcsicmp(ext, L".wbm") == 0) {
//		iconindex = IDI_WBM_ICON;
	} else if (_wcsicmp(ext, L".webm") == 0) {
		iconindex = IDI_WEBM_ICON;
	} else if (_wcsicmp(ext, L".wm") == 0) {
		iconindex = IDI_WM_ICON;
	} else if (_wcsicmp(ext, L".wma") == 0) {
		iconindex = IDI_WMA_ICON;
	} else if (_wcsicmp(ext, L".wmp") == 0) {
		iconindex = IDI_WMP_ICON;
	} else if (_wcsicmp(ext, L".wmv") == 0) {
		iconindex = IDI_WMV_ICON;
	} else if (_wcsicmp(ext, L".wv") == 0) {
		iconindex = IDI_WV_ICON;
	} else if (_wcsicmp(ext, L".opus") == 0) {
		iconindex = IDI_OPUS_ICON;
	}
	// playlists (need for compatibility with older versions)
	else if (_wcsicmp(ext, L".asx") == 0
			|| _wcsicmp(ext, L".bdmv") == 0
			|| _wcsicmp(ext, L".m3u") == 0
			|| _wcsicmp(ext, L".m3u8") == 0
			|| _wcsicmp(ext, L".mpcpl") == 0
			|| _wcsicmp(ext, L".mpls") == 0
			|| _wcsicmp(ext, L".pls") == 0
			|| _wcsicmp(ext, L".wpl") == 0
			|| _wcsicmp(ext, L".xspf") == 0
			|| _wcsicmp(ext, L".cue") == 0) {
		iconindex = IDI_PLAYLIST_ICON;
	}

	return iconindex;
}
