/*
 * (C) 2003-2006 Gabest
 * (C) 2006-2018 see Authors.txt
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

#include "stdafx.h"
#include "MainFrm.h"
#include "PlayerCaptureDialog.h"
#include <moreuuids.h>
#include "../../filters/muxer/WavDest/WavDest.h"
#include "../../filters/muxer/MatroskaMuxer/MatroskaMuxer.h"
#include "../../filters/muxer/DSMMuxer/DSMMuxer.h"


static bool LoadMediaType(CStringW displayName, AM_MEDIA_TYPE** ppmt)
{
	bool fRet = false;

	if (!ppmt) {
		return fRet;
	}

	*ppmt = (AM_MEDIA_TYPE*)CoTaskMemAlloc(sizeof(AM_MEDIA_TYPE));
	if (!*ppmt) {
		return fRet;
	}

	ZeroMemory(*ppmt, sizeof(AM_MEDIA_TYPE));

	CProfile& profile = AfxGetProfile();
	BYTE* pData;
	UINT len;
	if (profile.ReadBinary(IDS_R_CAPTURE L"\\" + CString(displayName), L"MediaType", &pData, len)) {
		if ( len != sizeof(AM_MEDIA_TYPE) ) {
			CoTaskMemFree(*ppmt);
			delete [] pData;
			return fRet;
		}
		memcpy(*ppmt, pData, len);
		delete [] pData;

		(*ppmt)->cbFormat = 0;
		(*ppmt)->pbFormat = nullptr;

		fRet = true;

		if (profile.ReadBinary(IDS_R_CAPTURE L"\\" + CString(displayName), L"Format", &pData, len)) {
			if ( !len ) {
				delete [] pData;
				return fRet;
			}
			(*ppmt)->cbFormat = len;
			(*ppmt)->pbFormat = (BYTE*)CoTaskMemAlloc(len);
			memcpy((*ppmt)->pbFormat, pData, len);
			delete [] pData;
		}
	}

	return fRet;
}

static void SaveMediaType(CStringW displayName, AM_MEDIA_TYPE* pmt)
{
	if (displayName.IsEmpty() || !pmt) {
		return;
	}

	AfxGetProfile().WriteBinary(IDS_R_CAPTURE L"\\" + CString(displayName), L"MediaType", (BYTE*)pmt, sizeof(AM_MEDIA_TYPE));
	AfxGetProfile().WriteBinary(IDS_R_CAPTURE L"\\" + CString(displayName), L"Format", pmt->pbFormat, pmt->cbFormat);
}

static void LoadDefaultCodec(std::vector<Codec>& codecs, CComboBox& box, const GUID& cat)
{
	int len = box.GetCount();
	if (len >= 0) {
		box.SetCurSel(0);
	}

	if (cat == GUID_NULL) {
		return;
	}

	CString displayName;
	AfxGetProfile().ReadString(IDS_R_CAPTURE L"\\" + CStringFromGUID(cat), L"DisplayName", displayName);

	for (int i = 0; i < len; i++) {
		int iSel = (int)box.GetItemData(i);
		if (iSel < 0) {
			continue;
		}

		Codec& c = codecs[iSel];
		if (displayName == c.displayName) {
			box.SetCurSel(i);
			if (!c.pBF) {
				c.pMoniker->BindToObject(nullptr, nullptr, IID_PPV_ARGS(&c.pBF));
			}
			break;
		}
	}
}

static void SaveDefaultCodec(std::vector<Codec>& codecs, const CComboBox& box, const GUID& cat)
{
	if (cat == GUID_NULL) {
		return;
	}

	CString guid = CStringFromGUID(cat);

	AfxGetProfile().DeleteSection(IDS_R_CAPTURE L"\\" + guid);

	int iSel = box.GetCurSel();
	if (iSel < 0) {
		return;
	}
	iSel = (int)box.GetItemData(iSel);
	if (iSel < 0) {
		return;
	}

	Codec& codec = codecs[iSel];

	AfxGetProfile().WriteString(IDS_R_CAPTURE L"\\" + guid, L"DisplayName", CString(codec.displayName));
}

static void SetupDefaultCaps(AM_MEDIA_TYPE* pmt, VIDEO_STREAM_CONFIG_CAPS& caps)
{
	ZeroMemory(&caps, sizeof(caps));

	if (!pmt) {
		return;
	}

	VIDEOINFOHEADER* vih = (VIDEOINFOHEADER*)pmt->pbFormat;
	UNREFERENCED_PARAMETER(vih);

	BITMAPINFOHEADER* bih = (pmt->formattype == FORMAT_VideoInfo)
							? &((VIDEOINFOHEADER*)pmt->pbFormat)->bmiHeader
							: (pmt->formattype == FORMAT_VideoInfo2)
							? &((VIDEOINFOHEADER2*)pmt->pbFormat)->bmiHeader
							: nullptr;
	if (!bih) {
		return;
	}

	caps.guid = GUID_NULL;
	caps.VideoStandard = 0;
	caps.InputSize.cx = bih->biWidth;
	caps.InputSize.cy = abs(bih->biHeight);
	caps.MinCroppingSize = caps.MaxCroppingSize = caps.InputSize;
	caps.CropGranularityX = caps.CropGranularityY = 1;
	caps.CropAlignX = caps.CropAlignY = 1;
	caps.MinOutputSize = CSize(64, 64);
	caps.MaxOutputSize = CSize(768, 576);
	caps.OutputGranularityX = 16;
	caps.OutputGranularityY = 1;
	caps.StretchTapsX = caps.StretchTapsY = 0;
	caps.ShrinkTapsX = caps.ShrinkTapsY = 0;
	caps.MinFrameInterval = 100000i64;
	caps.MaxFrameInterval = 100000000i64;
	caps.MinBitsPerSecond = caps.MaxBitsPerSecond = 0;
}

static void SetupDefaultCaps(AM_MEDIA_TYPE* pmt, AUDIO_STREAM_CONFIG_CAPS& caps)
{
	ZeroMemory(&caps, sizeof(caps));

	if (!pmt) {
		return;
	}

	WAVEFORMATEX* wfe = (WAVEFORMATEX*)pmt->pbFormat;

	caps.guid = GUID_NULL;
	caps.MinimumChannels = caps.MaximumChannels = wfe->nChannels;
	caps.ChannelsGranularity = 1;
	caps.MinimumBitsPerSample = caps.MaximumBitsPerSample = wfe->wBitsPerSample;
	caps.BitsPerSampleGranularity = 1;
	caps.MinimumSampleFrequency = caps.MaximumSampleFrequency = wfe->nSamplesPerSec;
	caps.SampleFrequencyGranularity = 1;
}

template<class T>
static void SetupMediaTypes(IAMStreamConfig* pAMSC, CFormatArray<T>& tfa, CComboBox& type, CComboBox& dim, CMediaType& mt)
{
	tfa.RemoveAll();
	type.ResetContent();
	dim.ResetContent();
	type.EnableWindow(FALSE);
	dim.EnableWindow(FALSE);

	if (!pAMSC) {
		return;
	}

	AM_MEDIA_TYPE* pcurmt = nullptr;
	pAMSC->GetFormat(&pcurmt);

	int iCount = 0, iSize;
	if (SUCCEEDED(pAMSC->GetNumberOfCapabilities(&iCount, &iSize))
			&& iSize == sizeof(T) && iCount > 0) {
		for (int i = 0; i < iCount; i++) {
			T caps;
			AM_MEDIA_TYPE* pmt = nullptr;
			if (SUCCEEDED(pAMSC->GetStreamCaps(i, &pmt, (BYTE*)&caps))) {
				tfa.AddFormat(pmt, caps);
			}
		}

		if (iSize == sizeof(VIDEO_STREAM_CONFIG_CAPS)) {
			for (size_t i = 0, cnt = tfa.GetCount(); i < cnt; i++) {
				if (tfa[i]->GetCount() != 1) {
					continue;
				}

				CFormatElem<T>* pfe = tfa[i]->GetAt(0);

				if (pfe->mt.formattype != FORMAT_VideoInfo
						&& pfe->mt.formattype != FORMAT_VideoInfo2) {
					continue;
				}

				static SIZE presets[] = {
					{160, 120}, {192, 144},
					{320, 240}, {384, 288},
					{480, 240}, {512, 288},
					{480, 360}, {512, 384},
					{640, 240}, {768, 288},
					{640, 480}, {768, 576},
					{704, 240}, {704, 288},
					{704, 480}, {704, 576},
					{720, 240}, {720, 288},
					{720, 480}, {720, 576},
					{768, 240}, {768, 288},
					{768, 480}, {768, 576},
				};

				VIDEO_STREAM_CONFIG_CAPS* pcaps = (VIDEO_STREAM_CONFIG_CAPS*)&pfe->caps;
				BITMAPINFOHEADER bihCur;
				ExtractBIH(&pfe->mt, &bihCur);

				for (size_t j = 0; j < _countof(presets); j++) {
					if (presets[j].cx == bihCur.biWidth
							&& presets[j].cy == abs(bihCur.biHeight)
							|| presets[j].cx < pcaps->MinOutputSize.cx
							|| presets[j].cx > pcaps->MaxOutputSize.cx
							|| presets[j].cy < pcaps->MinOutputSize.cy
							|| presets[j].cy > pcaps->MaxOutputSize.cy
							|| presets[j].cx % pcaps->OutputGranularityX
							|| presets[j].cy % pcaps->OutputGranularityY) {
						continue;
					}

					CMediaType mtCap = pfe->mt;

					if (mtCap.formattype == FORMAT_VideoInfo) {
						VIDEOINFOHEADER* vih = (VIDEOINFOHEADER*)mtCap.pbFormat;
						vih->bmiHeader.biWidth		= presets[j].cx;
						vih->bmiHeader.biHeight = presets[j].cy * (vih->bmiHeader.biHeight < 0 ? -1 : 1);
						vih->bmiHeader.biSizeImage	= presets[j].cx * presets[j].cy * vih->bmiHeader.biBitCount>>3;

						AM_MEDIA_TYPE* pmt = (AM_MEDIA_TYPE*)CoTaskMemAlloc(sizeof(AM_MEDIA_TYPE));
						CopyMediaType(pmt, &mtCap);
						tfa.AddFormat(pmt, pcaps, sizeof(*pcaps));

						if (presets[j].cx*3 != presets[j].cy*4) {
							int extra = mtCap.cbFormat - sizeof(VIDEOINFOHEADER);
							int bmiHeaderSize = sizeof(vih->bmiHeader) + extra;
							BYTE* pbmiHeader = DNew BYTE[bmiHeaderSize];
							memcpy(pbmiHeader, &vih->bmiHeader, bmiHeaderSize);
							mtCap.ReallocFormatBuffer(FIELD_OFFSET(VIDEOINFOHEADER2, bmiHeader) + bmiHeaderSize);
							VIDEOINFOHEADER2* vih2 = (VIDEOINFOHEADER2*)mtCap.pbFormat;
							memcpy(&vih2->bmiHeader, pbmiHeader, bmiHeaderSize);
							delete [] pbmiHeader;
							vih2->dwInterlaceFlags = vih2->dwCopyProtectFlags = 0;
							vih2->dwReserved1 = vih2->dwReserved2 = 0;
							vih2->dwPictAspectRatioX = 4;
							vih2->dwPictAspectRatioY = 3;

							AM_MEDIA_TYPE* pmt2 = (AM_MEDIA_TYPE*)CoTaskMemAlloc(sizeof(AM_MEDIA_TYPE));
							CopyMediaType(pmt2, &mtCap);
							tfa.AddFormat(pmt2, pcaps, sizeof(*pcaps));
						}
					} else if (mtCap.formattype == FORMAT_VideoInfo2) {
						VIDEOINFOHEADER2* vih2 = (VIDEOINFOHEADER2*)mtCap.pbFormat;
						vih2->bmiHeader.biWidth		= presets[j].cx;
						vih2->bmiHeader.biHeight = presets[j].cy * (vih2->bmiHeader.biHeight < 0 ? -1 : 1);
						vih2->bmiHeader.biSizeImage	= presets[j].cx * presets[j].cy * vih2->bmiHeader.biBitCount>>3;
						vih2->dwPictAspectRatioX	= 4;
						vih2->dwPictAspectRatioY	= 3;

						AM_MEDIA_TYPE* pmt = (AM_MEDIA_TYPE*)CoTaskMemAlloc(sizeof(AM_MEDIA_TYPE));
						CopyMediaType(pmt, &mtCap);
						tfa.AddFormat(pmt, pcaps, sizeof(*pcaps));
					}
				}
			}
		}
	}

	if (tfa.IsEmpty()) {
		if (pcurmt && (pcurmt->majortype == MEDIATYPE_Video || pcurmt->majortype == MEDIATYPE_Audio)) {
			AM_MEDIA_TYPE* pmt = (AM_MEDIA_TYPE*)CoTaskMemAlloc(sizeof(AM_MEDIA_TYPE));
			CopyMediaType(pmt, pcurmt);
			T caps;
			SetupDefaultCaps(pmt, caps);
			tfa.AddFormat(pmt, caps);
		} else {
			mt.majortype = GUID_NULL;
			if (pcurmt) {
				DeleteMediaType(pcurmt);
			}
			return;
		}
	}

	for (size_t i = 0, cnt = tfa.GetCount(); i < cnt; i++) {
		CFormat<T>* pf = tfa[i];
		AddStringData(type, pf->name, (DWORD_PTR)pf);
	}

	CFormat<T>* pf = nullptr;
	CFormatElem<T>* pfeCurrent = nullptr;

	if (!pcurmt) {
		pf = tfa[0];
		pfeCurrent = pf->GetAt(0);
	} else if (!tfa.FindFormat(pcurmt, nullptr, &pf, &pfeCurrent) && !tfa.FindFormat(pcurmt, &pf)) {
		if (pcurmt) {
			DeleteMediaType(pcurmt);
		}
		return;
	}

	for (size_t i = 0, cnt = pf->GetCount(); i < cnt; i++) {
		CFormatElem<T>* pfe = pf->GetAt(i);
		AddStringData(dim, tfa.MakeDimensionName(pfe), (DWORD_PTR)pfe);
	}

	int iType = type.SetCurSel(type.FindStringExact(0, pf->name));
	if (iType < 0 && type.GetCount()) {
		type.SetCurSel(0);
	}
	int iDim = dim.SetCurSel(dim.FindStringExact(0, tfa.MakeDimensionName(pfeCurrent)));
	//if (iDim < 0 && dim.GetCount()) dim.SetCurSel(iDim = 0);

	CorrectComboListWidth(type);
	CorrectComboListWidth(dim);

	if (iDim >= 0) {
		mt = ((CFormatElem<T>*)dim.GetItemData(iDim))->mt;
	} else if (pcurmt) {
		mt = *pcurmt;
	}

	type.EnableWindow(type.GetCount() > 0);
	dim.EnableWindow(dim.GetCount() > 0);

	if (pcurmt) {
		DeleteMediaType(pcurmt);
	}
}

template<class T>
static bool SetupDimension(CFormatArray<T>& tfa, CComboBox& type, CComboBox& dim)
{
	CString str;
	dim.GetWindowText(str);

	dim.ResetContent();
	dim.EnableWindow(FALSE);

	int iSel = type.GetCurSel();
	if (iSel < 0) {
		return false;
	}

	CFormat<T>* pf = (CFormat<T>*)type.GetItemData(iSel);

	for (int i = 0; i < (int)pf->GetCount(); i++) {
		CFormatElem<T>* pfe = pf->GetAt(i);
		AddStringData(dim, tfa.MakeDimensionName(pfe), (DWORD_PTR)pfe);
	}

	CorrectComboListWidth(dim);

	dim.SetCurSel(dim.FindStringExact(0, str));
	dim.EnableWindow(dim.GetCount() > 0);

	return(dim.GetCurSel() >= 0);
}

static void InitCodecList(std::vector<Codec>& codecs, CComboBox& box, const GUID& cat)
{
	codecs.clear();
	box.ResetContent();
	box.EnableWindow(FALSE);

	AddStringData(box, L"Uncompressed", -1);

	BeginEnumSysDev(cat, pMoniker) {
		Codec c;

		c.pMoniker = pMoniker;
		/*
		CComPtr<IBaseFilter> pBF;
		if (FAILED(pMoniker->BindToObject(0, 0, IID_PPV_ARGS(&pBF))) || !pBF) {
			continue;
		}
		c.pBF = pBF;
		*/
		CComHeapPtr<OLECHAR> strName;
		if (FAILED(pMoniker->GetDisplayName(nullptr, nullptr, &strName))) {
			continue;
		}

		c.displayName = strName;

		CComPtr<IPropertyBag> pPB;
		pMoniker->BindToStorage(0, 0, IID_PPV_ARGS(&pPB));

		CComVariant var;
		if (!pPB || FAILED(pPB->Read(L"FriendlyName", &var, nullptr))) {
			continue;
		}

		CStringW str = CStringW(c.displayName).MakeLower();
		if (str.Find(L"@device:sw:") == 0) {
			c.friendlyName = L"(DS)";
		}
		else if (str.Find(L"@device:cm:") == 0) {
			if (cat == CLSID_VideoCompressorCategory) {
				// for some unknown reason, the VfW codecs never added in x64 mode
				c.friendlyName = L"(VfW)";
			}
			else if (cat == CLSID_AudioCompressorCategory) {
				c.friendlyName = L"(ACM)";
			}
		}
#if 0 // TODO?
		else if (str.Find(L"@device:dmo:") == 0) {
			c.FriendlyName = L"(DMO)";
		}
#endif
		else {
			continue;
		}
		c.friendlyName.AppendFormat(L" %s", var.bstrVal);

		codecs.push_back(c);
		AddStringData(box, c.friendlyName, (int)codecs.size()-1);
	}
	EndEnumSysDev;

	box.EnableWindow(box.GetCount() > 1);

	CorrectComboListWidth(box);

	LoadDefaultCodec(codecs, box, cat);
}

static int ShowPPage(std::vector<Codec>& codecs, const CComboBox& box, HWND hWnd = nullptr)
{
	int iSel = box.GetCurSel();
	if (iSel < 0) {
		return -1;
	}

	iSel = (int)box.GetItemData(iSel);
	if (iSel < 0) {
		return -1;
	}

	Codec& c = codecs[iSel];

	if (!c.pBF) {
		c.pMoniker->BindToObject(nullptr, nullptr, IID_PPV_ARGS(&c.pBF));
	}

	if (CComQIPtr<ISpecifyPropertyPages> pSPP = c.pBF) {
		CAUUID caGUID;
		caGUID.pElems = nullptr;
		if (SUCCEEDED(pSPP->GetPages(&caGUID))) {
			IUnknown* lpUnk = nullptr;
			pSPP.QueryInterface(&lpUnk);
			OleCreatePropertyFrame(
				hWnd, 0, 0, CStringW(c.friendlyName),
				1, (IUnknown**)&lpUnk,
				caGUID.cElems, caGUID.pElems,
				0, 0, nullptr);
			lpUnk->Release();

			if (caGUID.pElems) {
				CoTaskMemFree(caGUID.pElems);
			}
		}
	} else if (CComQIPtr<IAMVfwCompressDialogs> pAMVfWCD = c.pBF) {
		if (pAMVfWCD->ShowDialog(VfwCompressDialog_QueryConfig, nullptr) == S_OK) {
			pAMVfWCD->ShowDialog(VfwCompressDialog_Config, hWnd);
		}
	}

	return iSel;
}

// CPlayerCaptureDialog dialog

//IMPLEMENT_DYNAMIC(CPlayerCaptureDialog, CResizableDialog)
CPlayerCaptureDialog::CPlayerCaptureDialog(CMainFrame* pMainFrame)
	: CResizableDialog(CPlayerCaptureDialog::IDD, nullptr)
	, m_pMainFrame(pMainFrame)
	, m_bInitialized(false)
	, m_vidfps(0)
	, m_nVidBuffers(50)
	, m_nAudBuffers(50)
	, m_nRecordTimerID(0)
	, m_fSepAudio(FALSE)
	, m_muxtype(0)
	, m_fVidOutput(TRUE)
	, m_fVidPreview(TRUE)
	, m_fAudOutput(TRUE)
	, m_fAudPreview(TRUE)
	, m_pVidBuffer(nullptr)
	, m_pAudBuffer(nullptr)
{
	EmptyVideo();
	EmptyAudio();
}

CPlayerCaptureDialog::~CPlayerCaptureDialog()
{
	EmptyVideo();
	EmptyAudio();
}

BOOL CPlayerCaptureDialog::Create(CWnd* pParent)
{
	return __super::Create(IDD, pParent);
}

void CPlayerCaptureDialog::DoDataExchange(CDataExchange* pDX)
{
	__super::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_COMBO4, m_vidinput);
	DDX_Control(pDX, IDC_COMBO1, m_vidtype);
	DDX_Control(pDX, IDC_COMBO5, m_viddimension);
	DDX_Control(pDX, IDC_SPIN1, m_vidhor);
	DDX_Control(pDX, IDC_SPIN2, m_vidver);
	DDX_Control(pDX, IDC_EDIT1, m_vidhoredit);
	DDX_Control(pDX, IDC_EDIT2, m_vidveredit);
	DDX_Control(pDX, IDC_EDIT3, m_vidfpsedit);
	DDX_Control(pDX, IDC_BUTTON1, m_vidsetres);
	DDX_Control(pDX, IDC_COMBO3, m_audinput);
	DDX_Control(pDX, IDC_COMBO2, m_audtype);
	DDX_Control(pDX, IDC_COMBO6, m_auddimension);
	DDX_Control(pDX, IDC_COMBO7, m_vidcodec);
	DDX_Control(pDX, IDC_COMBO9, m_vidcodectype);
	DDX_Control(pDX, IDC_COMBO10, m_vidcodecdimension);
	DDX_Check(pDX, IDC_CHECK1, m_fVidOutput);
	DDX_Control(pDX, IDC_CHECK1, m_vidoutput);
	DDX_Check(pDX, IDC_CHECK2, m_fVidPreview);
	DDX_Control(pDX, IDC_CHECK2, m_vidpreview);
	DDX_Control(pDX, IDC_COMBO8, m_audcodec);
	DDX_Control(pDX, IDC_COMBO12, m_audcodectype);
	DDX_Control(pDX, IDC_COMBO11, m_audcodecdimension);
	DDX_Check(pDX, IDC_CHECK3, m_fAudOutput);
	DDX_Control(pDX, IDC_CHECK3, m_audoutput);
	DDX_Check(pDX, IDC_CHECK4, m_fAudPreview);
	DDX_Control(pDX, IDC_CHECK4, m_audpreview);
	DDX_Text(pDX, IDC_EDIT4, m_file);
	DDX_Control(pDX, IDC_BUTTON2, m_recordbtn);
	DDX_Text(pDX, IDC_EDIT5, m_nVidBuffers);
	DDX_Text(pDX, IDC_EDIT6, m_nAudBuffers);
	DDX_Check(pDX, IDC_CHECK5, m_fSepAudio);
	DDX_CBIndex(pDX, IDC_COMBO14, m_muxtype);
	DDX_Control(pDX, IDC_COMBO14, m_muxctrl);
}

BOOL CPlayerCaptureDialog::PreTranslateMessage(MSG* pMsg)
{
	if (pMsg->message == WM_KEYDOWN) {
		if (pMsg->wParam == VK_RETURN) {
			CWnd* pFocused = GetFocus();
			if (pFocused && pFocused->m_hWnd == m_vidfpsedit.m_hWnd) {
				UpdateGraph();
			}
		}
	}

	return __super::PreTranslateMessage(pMsg);
}

void CPlayerCaptureBar::ReloadTranslatableResources()
{
	SetWindowText(ResStr(IDS_CAPTURE_SETTINGS));

	bool bWasInitialized = m_capdlg.IsInitialized();
	m_capdlg.DestroyWindow();
	m_capdlg.Create(this);
	m_capdlg.ShowWindow(SW_SHOWNORMAL);
	if (bWasInitialized) {
		m_capdlg.InitControls();
		m_capdlg.SetVideoInput(m_capdlg.GetVideoInput());
		m_capdlg.SetVideoChannel(m_capdlg.GetVideoChannel());
		m_capdlg.SetAudioInput(m_capdlg.GetAudioInput());
		m_capdlg.UpdateVideoControls();
		m_capdlg.UpdateAudioControls();
	}
}

void CPlayerCaptureDialog::InitControls()
{
	if (!m_bInitialized) {
		m_bInitialized = true;

		InitCodecList(m_pVidEncArray, m_vidcodec, CLSID_VideoCompressorCategory);
		UpdateVideoCodec();

		InitCodecList(m_pAudEncArray, m_audcodec, CLSID_AudioCompressorCategory);
		UpdateAudioCodec();

		CProfile& profile = AfxGetProfile();
		profile.ReadInt(IDS_R_CAPTURE, L"VidBuffers", m_nVidBuffers);
		profile.ReadInt(IDS_R_CAPTURE, L"AudBuffers", m_nAudBuffers);
		profile.ReadInt(IDS_R_CAPTURE, L"VidOutput", m_fVidOutput);
		profile.ReadInt(IDS_R_CAPTURE, L"AudOutput", m_fAudOutput);
		profile.ReadInt(IDS_R_CAPTURE, L"VidPreview", m_fVidPreview);
		profile.ReadInt(IDS_R_CAPTURE, L"AudPreview", m_fAudPreview);
		profile.ReadInt(IDS_R_CAPTURE, L"FileFormat", m_muxtype);
		profile.ReadString(IDS_R_CAPTURE, L"FileName", m_file);
		profile.ReadInt(IDS_R_CAPTURE, L"SepAudio", m_fSepAudio);

		CString dir = m_file.Left(m_file.ReverseFind('\\'));
		// Overwrite m_file if it isn't a valid path
		if (!PathFileExistsW(dir) || dir.IsEmpty()) {
			m_file.Empty();
			HRESULT hr = SHGetFolderPathW(nullptr, CSIDL_PERSONAL, nullptr, 0, m_file.GetBuffer(MAX_PATH));
			m_file.ReleaseBuffer();
			if (SUCCEEDED(hr)) {
				m_file.Append(L"\\MPC-BE Capture");
				if (!PathFileExistsW(m_file)) {
					VERIFY(CreateDirectoryW(m_file, nullptr));
				}
			} else {
				// Use current directory
				m_file.ReleaseBufferSetLength(GetCurrentDirectory(MAX_PATH, dir.GetBuffer(MAX_PATH)));
			}
			m_file.AppendFormat(L"\\%s_capture_[time].avi", AfxGetApp()->m_pszExeName);
		}

		m_muxctrl.AddString(L"AVI");
		m_muxctrl.AddString(L"Matroska");
		m_muxctrl.AddString(L"DirectShow Media");

		UpdateData(FALSE);

		OnChangeFileType();
	}
}

void CPlayerCaptureDialog::EmptyVideo()
{
	// first save channel from previous session

	if (m_pAMTuner && !m_vidDisplayName.IsEmpty()) {
		long lChannel = 0, lVivSub = 0, lAudSub = 0;
		m_pAMTuner->get_Channel(&lChannel, &lVivSub, &lAudSub);
		AfxGetProfile().WriteInt(IDS_R_CAPTURE L"\\" + CString(m_vidDisplayName), L"Channel", lChannel);
	}

	m_vfa.RemoveAll();

	m_pAMXB = nullptr;
	m_pAMTuner = nullptr;
	m_pAMVSC = nullptr;
	m_pAMVfwCD = nullptr;

	if (IsWindow(m_hWnd)) {
		m_vidinput.ResetContent();
		m_vidinput.EnableWindow(FALSE);
		m_vidtype.ResetContent();
		m_vidtype.EnableWindow(FALSE);
		m_viddimension.ResetContent();
		m_viddimension.EnableWindow(FALSE);
		m_vidhor.EnableWindow(FALSE);
		m_vidver.EnableWindow(FALSE);
		m_vidhoredit.EnableWindow(FALSE);
		m_vidveredit.EnableWindow(FALSE);
		m_vidfpsedit.EnableWindow(FALSE);
		m_vidfps = 0;
		m_vidsetres.EnableWindow(FALSE);
		UpdateData(FALSE);
	}
}

void CPlayerCaptureDialog::EmptyAudio()
{
	m_afa.RemoveAll();

	m_pAMASC = nullptr;
	m_pAMAIM.RemoveAll();

	if (IsWindow(m_hWnd)) {
		m_audinput.ResetContent();
		m_audinput.EnableWindow(FALSE);
		m_audtype.ResetContent();
		m_audtype.EnableWindow(FALSE);
		m_auddimension.ResetContent();
		m_auddimension.EnableWindow(FALSE);
		UpdateData(FALSE);
	}
}

void CPlayerCaptureDialog::UpdateMediaTypes()
{
	UpdateData();

	// fps

	CString fps;
	m_vidfpsedit.GetWindowText(fps);
	if (!fps.IsEmpty()) {
		float ffps;
		swscanf_s(fps, L"%f", &ffps);
		if (ffps > 0) {
			m_vidfps = ffps;
		}
	}

	// video

	{
		AM_MEDIA_TYPE* pmt = nullptr;
		VIDEO_STREAM_CONFIG_CAPS* pcaps = nullptr;

		int i = m_viddimension.GetCurSel();
		if (i >= 0) {
			pmt = (AM_MEDIA_TYPE*)CoTaskMemAlloc(sizeof(AM_MEDIA_TYPE));
			CopyMediaType(pmt, &((CVidFormatElem*)m_viddimension.GetItemData(i))->mt);
			pcaps = &((CVidFormatElem*)m_viddimension.GetItemData(i))->caps;
		} else if (m_pAMVSC) {
			m_pAMVSC->GetFormat(&pmt);
		}

		if (pmt) {
			if (m_vidfps > 0) {
				REFERENCE_TIME atpf = (REFERENCE_TIME)(10000000.0 / m_vidfps);

				if (pcaps) {
					// FIXME: some drivers do not set the interval right and they still accept the preferable but unfortunately out-of-range fps
					//atpf = std::clamp(atpf, pcaps->MinFrameInterval, pcaps->MaxFrameInterval);
				}

				if (pmt->formattype == FORMAT_VideoInfo) {
					((VIDEOINFOHEADER*)pmt->pbFormat)->AvgTimePerFrame = atpf;
				} else if (pmt->formattype == FORMAT_VideoInfo2) {
					((VIDEOINFOHEADER2*)pmt->pbFormat)->AvgTimePerFrame = atpf;
				}
			}

			BITMAPINFOHEADER* bih = (pmt->formattype == FORMAT_VideoInfo)
									? &((VIDEOINFOHEADER*)pmt->pbFormat)->bmiHeader
									: (pmt->formattype == FORMAT_VideoInfo2)
									? &((VIDEOINFOHEADER2*)pmt->pbFormat)->bmiHeader
									: nullptr;
			if (bih) {
				bih->biWidth = m_vidhor.GetPos32();
				bih->biHeight = m_vidver.GetPos32();
				bih->biSizeImage = bih->biWidth*bih->biHeight*bih->biBitCount>>3;
			}
			SaveMediaType(m_vidDisplayName, pmt);

			m_mtv = *pmt;
			DeleteMediaType(pmt);
		}
	}

	// audio

	{
		AM_MEDIA_TYPE* pmt = nullptr;

		int i = m_auddimension.GetCurSel();
		if (i >= 0) {
			pmt = (AM_MEDIA_TYPE*)CoTaskMemAlloc(sizeof(AM_MEDIA_TYPE));
			CopyMediaType(pmt, &((CAudFormatElem*)m_auddimension.GetItemData(i))->mt);
		} else if (m_pAMASC) {
			m_pAMASC->GetFormat(&pmt);
		}

		if (pmt) {
			SaveMediaType(m_audDisplayName, pmt);

			m_mta = *pmt;
			DeleteMediaType(pmt);
		}
	}
}

void CPlayerCaptureDialog::UpdateUserDefinableControls()
{
	int iSel = m_viddimension.GetCurSel();
	if (iSel < 0) {
		return;
	}

	CVidFormatElem* pvfe = (CVidFormatElem*)m_viddimension.GetItemData(iSel);
	if (!pvfe) {
		return;
	}

	if (!m_pAMVSC) {
		return;
	}

	AM_MEDIA_TYPE* pmt = nullptr;
	m_pAMVSC->GetFormat(&pmt);
	if (!pmt) {
		return;
	}

	BITMAPINFOHEADER* bih = (pmt->formattype == FORMAT_VideoInfo)
							? &((VIDEOINFOHEADER*)pmt->pbFormat)->bmiHeader
							: (pmt->formattype == FORMAT_VideoInfo2)
							? &((VIDEOINFOHEADER2*)pmt->pbFormat)->bmiHeader
							: nullptr;

	if (!bih) {
		return;
	}

	UDACCEL ua[3] = {{0,0},{2,0},{4,0}};

	int w = m_vidhor.GetPos32(), h = m_vidver.GetPos32();
	UNREFERENCED_PARAMETER(w);
	UNREFERENCED_PARAMETER(h);

	m_vidhor.SetRange32(pvfe->caps.MinOutputSize.cx, pvfe->caps.MaxOutputSize.cx);
	/*
	// FIXME: bt8x8 drivers seem to crop the right side in yuv2 mode if the width is not dividable by 64
	if (bih->biCompression == mmioFOURCC('Y','U','Y','2')) {
		pvfe->caps.OutputGranularityX = 64;
	}
	*/
	ua[0].nInc = pvfe->caps.OutputGranularityX;
	ua[1].nInc = pvfe->caps.OutputGranularityX*2;
	ua[2].nInc = pvfe->caps.OutputGranularityX*4;
	m_vidhor.SetAccel(3, ua);

	m_vidver.SetRange32(pvfe->caps.MinOutputSize.cy, pvfe->caps.MaxOutputSize.cy);
	ua[0].nInc = pvfe->caps.OutputGranularityY;
	ua[1].nInc = pvfe->caps.OutputGranularityY*2;
	ua[2].nInc = pvfe->caps.OutputGranularityY*4;
	m_vidver.SetAccel(3, ua);

	m_vidhor.SetPos32(bih->biWidth);
	m_vidver.SetPos32(abs(bih->biHeight));

	CString fps;
	fps.Format(L"%.4f", (float)(10000000.0 / ((VIDEOINFOHEADER*)pmt->pbFormat)->AvgTimePerFrame));
	m_vidfpsedit.SetWindowText(fps);

	DeleteMediaType(pmt);
}

void CPlayerCaptureDialog::UpdateVideoCodec()
{
	int iSel = m_vidcodec.GetCurSel();
	if (iSel >= 0) {
		iSel = (int)m_vidcodec.GetItemData(iSel);
	}

	m_pVidEnc = iSel < 0 ? nullptr : m_pVidEncArray[iSel].pBF;
	m_pVidEncMoniker = iSel < 0 ? nullptr : m_pVidEncArray[iSel].pMoniker;

	//CString displayName = iSel < 0 ? L"" : CString(m_pVidEncArray[iSel].displayName.m_str);
	CComQIPtr<IAMStreamConfig> pAMSC = GetFirstPin(m_pVidEnc, PINDIR_OUTPUT);

	SetupMediaTypes(pAMSC, m_vcfa, m_vidcodectype, m_vidcodecdimension, m_mtcv);

	SaveDefaultCodec(m_pVidEncArray, m_vidcodec, CLSID_VideoCompressorCategory);

	//SaveMediaType(displayName, &m_mtcv);
}

void CPlayerCaptureDialog::UpdateAudioCodec()
{
	int iSel = m_audcodec.GetCurSel();
	if (iSel >= 0) {
		iSel = (int)m_audcodec.GetItemData(iSel);
	}

	m_pAudEnc = iSel < 0 ? nullptr : m_pAudEncArray[iSel].pBF;
	m_pAudEncMoniker = iSel < 0 ? nullptr : m_pAudEncArray[iSel].pMoniker;

	//CString displayName = iSel < 0 ? L"" : CString(m_pAudEncArray[iSel].displayName.m_str);
	CComQIPtr<IAMStreamConfig> pAMSC = GetFirstPin(m_pAudEnc, PINDIR_OUTPUT);

	SetupMediaTypes(pAMSC, m_acfa, m_audcodectype, m_audcodecdimension, m_mtca);

	SaveDefaultCodec(m_pAudEncArray, m_audcodec, CLSID_AudioCompressorCategory);

	//SaveMediaType(displayName, &m_mtca);
}

void CPlayerCaptureDialog::UpdateMuxer()
{
	m_pMux = nullptr;
	m_pAudMux = nullptr;

	UpdateData();

	HRESULT hr;

	if (m_muxtype == 0) {
		m_pMux.CoCreateInstance(CLSID_AviDest);
	} else if (m_muxtype == 1) {
		m_pMux = DNew CMatroskaMuxerFilter(nullptr, &hr);
	} else if (m_muxtype == 2) {
		m_pMux = DNew CDSMMuxerFilter(nullptr, &hr);
	} else {
		return;
	}

	if (m_fSepAudio) {
		m_pAudMux = DNew CWavDestFilter(nullptr, &hr);
	}
}

void CPlayerCaptureDialog::UpdateOutputControls()
{
	UpdateData();

	m_recordbtn.EnableWindow(!m_file.IsEmpty() && (m_pAMVSC && m_fVidOutput || m_pAMASC && m_fAudOutput));
	m_vidcodec.EnableWindow(TRUE);
	m_audcodec.EnableWindow(TRUE);
}

void CPlayerCaptureDialog::UpdateGraph()
{
	UpdateMediaTypes();

	m_pMainFrame->BuildGraphVideoAudio(m_fVidPreview, false, m_fAudPreview, false);

	UpdateUserDefinableControls();
}

void CPlayerCaptureDialog::EnableControls(CWnd* pWnd, bool fEnable)
{
	if (fEnable) {
		for (CWnd* pChild = pWnd->GetWindow(GW_CHILD); pChild; pChild = pChild->GetNextWindow()) {
			if (const auto it = m_wndenabledmap.find(pChild->m_hWnd); it != m_wndenabledmap.end()) {
				pChild->EnableWindow((*it).second);
			}
			EnableControls(pChild, fEnable);
		}

		if (pWnd->m_hWnd == m_hWnd) {
			m_wndenabledmap.clear();
		}

		m_recordbtn.SetWindowText(ResStr(IDS_RECORD_START));
	} else {
		if (pWnd->m_hWnd == m_hWnd) {
			m_wndenabledmap.clear();
		}

		for (CWnd* pChild = pWnd->GetWindow(GW_CHILD); pChild; pChild = pChild->GetNextWindow()) {
			m_wndenabledmap[pChild->m_hWnd] = pChild->IsWindowEnabled();
			pChild->EnableWindow(FALSE);
			EnableControls(pChild, fEnable);
		}

		m_recordbtn.EnableWindow(TRUE);
		m_recordbtn.SetWindowText(ResStr(IDS_RECORD_STOP));
	}
}

void CPlayerCaptureDialog::SetupVideoControls(
	CStringW displayName,
	IAMStreamConfig* pAMSC, IAMCrossbar* pAMXB, IAMTVTuner* pAMTuner)
{
	EmptyVideo();

	m_vidDisplayName = displayName;
	m_pAMXB = pAMXB;
	m_pAMTuner = pAMTuner;
	m_pAMVSC = pAMSC;

	UpdateVideoControls();
}

void CPlayerCaptureDialog::SetupVideoControls(
	CStringW displayName,
	IAMStreamConfig* pAMSC, IAMVfwCaptureDialogs* pAMVfwCD)
{
	EmptyVideo();

	m_vidDisplayName = displayName;
	m_pAMVSC = pAMSC;
	m_pAMVfwCD = pAMVfwCD;

	UpdateVideoControls();
}

void CPlayerCaptureDialog::UpdateVideoControls()
{
	ASSERT(!m_pAMXB || !m_pAMVfwCD);

	// crossbar

	if (m_pAMXB) {
		long OutputPinCount, InputPinCount;
		if (SUCCEEDED(m_pAMXB->get_PinCounts(&OutputPinCount, &InputPinCount))) {
			for (int i = 0; i < InputPinCount; i++) {
				long PinIndexRelated, PhysicalType;
				if (FAILED(m_pAMXB->get_CrossbarPinInfo(TRUE, i, &PinIndexRelated, &PhysicalType))) {
					continue;
				}

				if (PhysicalType >= PhysConn_Audio_Tuner) {
					continue;
				}

				CString str;
				switch (PhysicalType) {
					case PhysConn_Video_Tuner:
						str = L"Tuner";
						break;
					case PhysConn_Video_Composite:
						str = L"Composite";
						break;
					case PhysConn_Video_SVideo:
						str = L"SVideo";
						break;
					case PhysConn_Video_RGB:
						str = L"RGB";
						break;
					case PhysConn_Video_YRYBY:
						str = L"YRYBY";
						break;
					case PhysConn_Video_SerialDigital:
						str = L"SerialDigital";
						break;
					case PhysConn_Video_ParallelDigital:
						str = L"ParallelDigital";
						break;
					case PhysConn_Video_SCSI:
						str = L"SCSI";
						break;
					case PhysConn_Video_AUX:
						str = L"AUX";
						break;
					case PhysConn_Video_1394:
						str = L"1394";
						break;
					case PhysConn_Video_USB:
						str = L"USB";
						break;
					case PhysConn_Video_VideoDecoder:
						str = L"VideoDecoder";
						break;
					case PhysConn_Video_VideoEncoder:
						str = L"VideoEncoder";
						break;
					case PhysConn_Video_SCART:
						str = L"SCART";
						break;
					default:
						str.Format(L"PhysicalType %ld", PhysicalType);
						break;
				}

				AddStringData(m_vidinput, str, i);
			}
		}

		if (m_vidinput.GetCount() > 0) {
			m_vidinput.EnableWindow(TRUE);

			if (SUCCEEDED(m_pAMXB->get_PinCounts(&OutputPinCount, &InputPinCount))) {
				for (int i = 0; i < OutputPinCount; i++) {
					long InputPinIndex;
					if (S_OK == m_pAMXB->get_IsRoutedTo(i, &InputPinIndex)) {
						for (int j = 0; j < m_vidinput.GetCount(); j++) {
							if (m_vidinput.GetItemData(j) == (DWORD_PTR)InputPinIndex) {
								m_vidinput.SetCurSel(j);
								i = OutputPinCount;
								break;
							}
						}
					}
				}
			}
			OnVideoInput();
		}
	}

	// VFW capture dialog

	if (m_pAMVfwCD) {
		if (S_OK == m_pAMVfwCD->HasDialog(VfwCaptureDialog_Source)) {
			AddStringData(m_vidinput, L"Source", VfwCaptureDialog_Source);
		}
		if (S_OK == m_pAMVfwCD->HasDialog(VfwCaptureDialog_Format)) {
			AddStringData(m_vidinput, L"Format", VfwCaptureDialog_Format);
		}
		if (S_OK == m_pAMVfwCD->HasDialog(VfwCaptureDialog_Display)) {
			AddStringData(m_vidinput, L"Display", VfwCaptureDialog_Display);
		}

		if (m_vidinput.GetCount() > 0) {
			m_vidinput.EnableWindow(TRUE);
			m_vidinput.SetCurSel(0);
		}
	}

	// tuner

	if (m_pAMTuner) {
		// TODO:...
	}

	// streamconfig

	if (m_pAMVSC) {
		AM_MEDIA_TYPE* pmt;
		if (LoadMediaType(m_vidDisplayName, &pmt)) {
			m_pAMVSC->SetFormat(pmt);
			DeleteMediaType(pmt);
		}

		SetupMediaTypes(m_pAMVSC, m_vfa, m_vidtype, m_viddimension, m_mtv);
	}

	if (m_vidtype.GetCount() > 0) {
		m_vidfpsedit.EnableWindow(TRUE);
		m_vidhor.EnableWindow(TRUE);
		m_vidver.EnableWindow(TRUE);
		m_vidhoredit.EnableWindow(TRUE);
		m_vidveredit.EnableWindow(TRUE);
		m_vidsetres.EnableWindow(TRUE);
	}

	{
		m_vidoutput.EnableWindow(TRUE);
		m_vidpreview.EnableWindow(TRUE);
	}

	UpdateMediaTypes();

	UpdateUserDefinableControls();

	UpdateOutputControls();
}

void CPlayerCaptureDialog::SetupAudioControls(
	CStringW displayName,
	IAMStreamConfig* pAMSC, const CInterfaceArray<IAMAudioInputMixer>& pAMAIM)
{
	EmptyAudio();

	m_audDisplayName = displayName;
	m_pAMASC = pAMSC;
	if (!pAMAIM.IsEmpty()) {
		m_pAMAIM.Copy(pAMAIM);
	}

	UpdateAudioControls();
}

void CPlayerCaptureDialog::UpdateAudioControls()
{
	// input selection

	if (!m_pAMAIM.IsEmpty()) {
		size_t iSel = SIZE_T_MAX;

		for (size_t i = 0; i < m_pAMAIM.GetCount(); i++) {
			CComQIPtr<IPin> pPin = m_pAMAIM[i];
			AddStringData(m_audinput, GetPinName(pPin), i);

			BOOL fEnable;
			if (SUCCEEDED(m_pAMAIM[i]->get_Enable(&fEnable)) && fEnable) {
				iSel = i;
			}
		}

		if (m_audinput.GetCount() > 0) {
			SelectByItemData(m_audinput, iSel);
			m_audinput.EnableWindow(TRUE);
		}
	}

	// stream config

	if (m_pAMASC) {
		AM_MEDIA_TYPE* pmt;
		if (LoadMediaType(m_audDisplayName, &pmt)) {
			m_pAMASC->SetFormat(pmt);
			DeleteMediaType(pmt);
		}

		SetupMediaTypes(m_pAMASC, m_afa, m_audtype, m_auddimension, m_mta);
	}

	//if (!m_audtype.IsEmpty())
	{
		m_audoutput.EnableWindow(TRUE);
		m_audpreview.EnableWindow(TRUE);
	}

	UpdateMediaTypes();

	UpdateUserDefinableControls();

	UpdateOutputControls();
}

bool CPlayerCaptureDialog::IsTunerActive()
{
	int iSel = m_vidinput.GetCurSel();
	if (iSel < 0) {
		return false;
	}
	iSel = (int)m_vidinput.GetItemData(iSel);
	if (iSel < 0) {
		return false;
	}

	long pinIndexRelated = -1, physicalType = -1;
	return(m_pAMXB
		   && SUCCEEDED(m_pAMXB->get_CrossbarPinInfo(TRUE, iSel, &pinIndexRelated, &physicalType))
		   && physicalType == PhysConn_Video_Tuner);
}

bool CPlayerCaptureDialog::SetVideoInput(int input)
{
	if (!m_pAMXB || input < 0) {
		return false;
	}

	for (int i = 0; i < m_vidinput.GetCount(); i++) {
		if (m_vidinput.GetItemData(i) == (DWORD_PTR)input) {
			m_vidinput.SetCurSel(i);
			OnVideoInput();
			return true;
		}
	}

	return false;
}

bool CPlayerCaptureDialog::SetVideoChannel(int channel)
{
	if (!m_pAMTuner || channel < 0) {
		return false;
	}

	return SUCCEEDED(m_pAMTuner->put_Channel(channel, AMTUNER_SUBCHAN_DEFAULT, AMTUNER_SUBCHAN_DEFAULT));
}

bool CPlayerCaptureDialog::SetAudioInput(int input)
{
	if (input < 0) {
		return false;
	}

	for (int i = 0; i < m_audinput.GetCount(); i++) {
		if (m_audinput.GetItemData(i) == (DWORD_PTR)input) {
			m_audinput.SetCurSel(i);
			OnAudioInput();
			return true;
		}
	}

	return false;
}

int CPlayerCaptureDialog::GetVideoInput() const
{
	int i = m_vidinput.GetCurSel();
	if (i < 0) {
		return -1;
	}
	return (int)m_vidinput.GetItemData(i);
}

int CPlayerCaptureDialog::GetVideoChannel()
{
	long lChannel = -1, lVivSub = -1, lAudSub = -1;
	return m_pAMTuner && SUCCEEDED(m_pAMTuner->get_Channel(&lChannel, &lVivSub, &lAudSub)) ? lChannel : -1;
}

int CPlayerCaptureDialog::GetAudioInput() const
{
	int i = m_audinput.GetCurSel();
	if (i < 0) {
		return -1;
	}
	return (int)m_audinput.GetItemData(i);
}

BEGIN_MESSAGE_MAP(CPlayerCaptureDialog, CResizableDialog)
	ON_WM_DESTROY()
	ON_CBN_SELCHANGE(IDC_COMBO4, OnVideoInput)
	ON_CBN_SELCHANGE(IDC_COMBO1, OnVideoType)
	ON_CBN_SELCHANGE(IDC_COMBO5, OnVideoDimension)
	ON_BN_CLICKED(IDC_BUTTON1, OnOverrideVideoDimension)
	ON_CBN_SELCHANGE(IDC_COMBO3, OnAudioInput)
	ON_CBN_SELCHANGE(IDC_COMBO2, OnAudioType)
	ON_CBN_SELCHANGE(IDC_COMBO6, OnAudioDimension)
	ON_BN_CLICKED(IDC_CHECK1, OnRecordVideo)
	ON_CBN_SELCHANGE(IDC_COMBO7, OnVideoCodec)
	ON_CBN_SELCHANGE(IDC_COMBO9, OnVideoCodecType)
	ON_CBN_SELCHANGE(IDC_COMBO10, OnVideoCodecDimension)
	ON_BN_CLICKED(IDC_CHECK3, OnRecordAudio)
	ON_CBN_SELCHANGE(IDC_COMBO8, OnAudioCodec)
	ON_CBN_SELCHANGE(IDC_COMBO12, OnAudioCodecType)
	ON_CBN_SELCHANGE(IDC_COMBO11, OnAudioCodecDimension)
	ON_BN_CLICKED(IDC_BUTTON3, OnOpenFile)
	ON_BN_CLICKED(IDC_BUTTON2, OnRecord)
	ON_EN_CHANGE(IDC_EDIT5, OnChangeVideoBuffers)
	ON_EN_CHANGE(IDC_EDIT6, OnChangeAudioBuffers)
	ON_WM_TIMER()
	ON_BN_CLICKED(IDC_CHECK2, OnBnClickedVidAudPreview)
	ON_BN_CLICKED(IDC_CHECK4, OnBnClickedVidAudPreview)
	ON_BN_CLICKED(IDC_CHECK5, OnBnClickedAudioToWav)
	ON_CBN_SELCHANGE(IDC_COMBO14, OnChangeFileType)
END_MESSAGE_MAP()

// CPlayerCaptureDialog message handlers

BOOL CPlayerCaptureDialog::OnInitDialog()
{
	__super::OnInitDialog();

	return FALSE;  // return FALSE so that the dialog does not steal focus
	// EXCEPTION: OCX Property Pages should return FALSE
}

void CPlayerCaptureDialog::OnDestroy()
{
	if (m_bInitialized) {
		UpdateData();

		CProfile& profile = AfxGetProfile();
		profile.WriteInt(IDS_R_CAPTURE, L"VidOutput", m_fVidOutput);
		profile.WriteInt(IDS_R_CAPTURE, L"AudOutput", m_fAudOutput);
		profile.WriteInt(IDS_R_CAPTURE, L"VidPreview", m_fVidPreview);
		profile.WriteInt(IDS_R_CAPTURE, L"AudPreview", m_fAudPreview);
		profile.WriteInt(IDS_R_CAPTURE, L"FileFormat", m_muxtype);
		profile.WriteString(IDS_R_CAPTURE, L"FileName", m_file);
		profile.WriteInt(IDS_R_CAPTURE, L"SepAudio", m_fSepAudio);

		m_bInitialized = false;
	}

	__super::OnDestroy();
}

void CPlayerCaptureDialog::OnVideoInput()
{
	int iSel = m_vidinput.GetCurSel();
	if (iSel < 0) {
		return;
	}
	iSel = (int)m_vidinput.GetItemData(iSel);
	if (iSel < 0) {
		return;
	}

	if (m_pAMXB) {
		long PinIndexRelated, PhysicalType;
		if (FAILED(m_pAMXB->get_CrossbarPinInfo(TRUE, iSel, &PinIndexRelated, &PhysicalType))) {
			return;
		}

		long OutputPinCount, InputPinCount;
		if (FAILED(m_pAMXB->get_PinCounts(&OutputPinCount, &InputPinCount))) {
			return;
		}

		for (int i = 0; i < OutputPinCount; i++) {
			if (S_OK == m_pAMXB->CanRoute(i, iSel)) {
				m_pAMXB->Route(i, iSel);
				break;
			}
		}

		if (PinIndexRelated >= 0) {
			for (int i = 0; i < OutputPinCount; i++) {
				if (S_OK == m_pAMXB->CanRoute(i, PinIndexRelated)) {
					m_pAMXB->Route(i, PinIndexRelated);
					break;
				}
			}
		}
	} else if (m_pAMVfwCD) {
		if (S_OK == m_pAMVfwCD->HasDialog(iSel)) {
			HRESULT hr = m_pAMVfwCD->ShowDialog(iSel, m_hWnd);

			if (VFW_E_NOT_STOPPED == hr) {
				m_pMainFrame->SendMessage(WM_COMMAND, ID_PLAY_STOP);
				hr = m_pAMVfwCD->ShowDialog(iSel, m_hWnd);
				m_pMainFrame->SendMessage(WM_COMMAND, ID_PLAY_PLAY);
			}

			if (VFW_E_CANNOT_CONNECT == hr) {
				UpdateGraph();
			}
		}
	}
}

void CPlayerCaptureDialog::OnVideoType()
{
	if (SetupDimension(m_vfa, m_vidtype, m_viddimension)) {
		OnVideoDimension();
	}
}

void CPlayerCaptureDialog::OnVideoDimension()
{
	int iSel = m_viddimension.GetCurSel();
	if (iSel < 0) {
		return;
	}

	CVidFormatElem* pvfe = (CVidFormatElem*)m_viddimension.GetItemData(iSel);
	if (!pvfe) {
		return;
	}

	BITMAPINFOHEADER* bih = (pvfe->mt.formattype == FORMAT_VideoInfo)
							? &((VIDEOINFOHEADER*)pvfe->mt.pbFormat)->bmiHeader
							: (pvfe->mt.formattype == FORMAT_VideoInfo2)
							? &((VIDEOINFOHEADER2*)pvfe->mt.pbFormat)->bmiHeader
							: nullptr;
	if (!bih) {
		return;
	}

	m_vidhor.SetRange32(0, UD_MAXVAL);
	m_vidver.SetRange32(0, UD_MAXVAL);
	m_vidhor.SetPos32(bih->biWidth);
	m_vidver.SetPos32(abs(bih->biHeight));
	CString fps;
	fps.Format(L"%.4f", (float)(10000000.0 / ((VIDEOINFOHEADER*)pvfe->mt.pbFormat)->AvgTimePerFrame));
	m_vidfpsedit.SetWindowText(fps);

	UpdateGraph();
}

void CPlayerCaptureDialog::OnOverrideVideoDimension()
{
	UpdateGraph();
}

void CPlayerCaptureDialog::OnAudioInput()
{
	int iSel = m_audinput.GetCurSel();

	for (int i = 0; i < (int)m_pAMAIM.GetCount(); i++) {
		m_pAMAIM[m_audinput.GetItemData(i)]->put_Enable(i == iSel ? TRUE : FALSE);
	}
}

void CPlayerCaptureDialog::OnAudioType()
{
	if (SetupDimension(m_afa, m_audtype, m_auddimension)) {
		OnAudioDimension();
	}
}

void CPlayerCaptureDialog::OnAudioDimension()
{
	UpdateGraph();
}

void CPlayerCaptureDialog::OnRecordVideo()
{
	UpdateOutputControls();
}

void CPlayerCaptureDialog::OnVideoCodec()
{
	ShowPPage(m_pVidEncArray, m_vidcodec, m_hWnd);
	UpdateVideoCodec();
}

void CPlayerCaptureDialog::OnVideoCodecType()
{
	if (SetupDimension(m_vcfa, m_vidcodectype, m_vidcodecdimension)) {
		OnVideoCodecDimension();
	}
}

void CPlayerCaptureDialog::OnVideoCodecDimension()
{
	int i = m_vidcodecdimension.GetCurSel();
	if (i >= 0) {
		m_mtcv = ((CVidFormatElem*)m_vidcodecdimension.GetItemData(i))->mt;

		// we have to recreate the encoder, otherwise it will accept the new media type for only the first time
		m_pVidEnc = nullptr;
		m_pVidEncMoniker->BindToObject(0, 0, IID_PPV_ARGS(&m_pVidEnc));
	}
}

void CPlayerCaptureDialog::OnRecordAudio()
{
	UpdateOutputControls();
}

void CPlayerCaptureDialog::OnAudioCodec()
{
	ShowPPage(m_pAudEncArray, m_audcodec, m_hWnd);
	UpdateAudioCodec();
}

void CPlayerCaptureDialog::OnAudioCodecType()
{
	if (SetupDimension(m_acfa, m_audcodectype, m_audcodecdimension)) {
		OnAudioCodecDimension();
	}
}

void CPlayerCaptureDialog::OnAudioCodecDimension()
{
	int i = m_audcodecdimension.GetCurSel();
	if (i >= 0) {
		m_mtca = ((CAudFormatElem*)m_audcodecdimension.GetItemData(i))->mt;

		// we have to recreate the encoder, otherwise it will accept the new media type for only the first time
		m_pAudEnc = nullptr;
		m_pAudEncMoniker->BindToObject(0, 0, IID_PPV_ARGS(&m_pAudEnc));
		/*
		SaveMediaType(
			CString(m_pAudEncArray[GetCurItemData(m_audcodec)].displayName.m_str),
			&m_mtca);
		*/
	}
}

void CPlayerCaptureDialog::OnOpenFile()
{
	CFileDialog fd(FALSE, nullptr, nullptr,
				   OFN_EXPLORER|OFN_ENABLESIZING|OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT|OFN_NOCHANGEDIR,
				   L"Media files (*.avi,*.mkv,*.dsm)|*.avi;*.mkv;*.dsm|", this, 0);

	if (fd.DoModal() == IDOK) {
		CString str = fd.GetPathName();

		CString ext = str.Mid(str.ReverseFind('.')+1).MakeLower();
		if (ext == L"avi") {
			m_muxtype = 0;
		} else if (ext == L"mkv") {
			m_muxtype = 1;
		} else if (ext == L"dsm") {
			m_muxtype = 2;
		} else {
			if (m_muxtype == 0) {
				str += L".avi";
			} else if (m_muxtype == 1) {
				str += L".mkv";
			} else if (m_muxtype == 2) {
				str += L".dsm";
			}
		}

		m_file = str;

		UpdateData(FALSE);
	}

	UpdateOutputControls();
}

void CPlayerCaptureDialog::OnRecord()
{
	UpdateData();

	if (!m_pMainFrame->m_fCapturing) {
		UpdateMuxer();

		CComQIPtr<IFileSinkFilter2> pFSF = m_pMux;
		if (pFSF) {
			m_pDst = m_pMux;
		} else {
			m_pDst = nullptr;
			m_pDst.CoCreateInstance(CLSID_FileWriter);
			pFSF = m_pDst;
		}

		// Replace [time] with current timestamp in the file name.
		CString file = m_file;
		CString sTime = CTime::GetCurrentTime().Format(L"%Y-%m-%d_%H-%M-%S");
		file.Replace(L"[time]", sTime);

		if (!pFSF
				|| FAILED(pFSF->SetFileName(CStringW(file), nullptr))
				|| FAILED(pFSF->SetMode(AM_FILE_OVERWRITE))) {
			MessageBoxW(ResStr(IDS_CAPTURE_ERROR_OUT_FILE), ResStr(IDS_CAPTURE_ERROR), MB_ICONERROR | MB_OK);
			return;
		}

		CString audfn = file.Left(file.ReverseFind('.')+1);
		if (m_fSepAudio && m_fAudOutput && m_pAudMux && !audfn.IsEmpty()) {
			audfn += L"wav";

			CComQIPtr<IFileSinkFilter2> pFSFAudioMux = m_pAudMux;
			if (pFSFAudioMux) {
				m_pAudDst = m_pAudMux;
			} else {
				m_pAudDst = nullptr;
				m_pAudDst.CoCreateInstance(CLSID_FileWriter);
				pFSFAudioMux = m_pAudDst;
			}

			if (!pFSFAudioMux
					|| FAILED(pFSFAudioMux->SetFileName(CStringW(audfn), nullptr))
					|| FAILED(pFSFAudioMux->SetMode(AM_FILE_OVERWRITE))) {
				MessageBoxW(ResStr(IDS_CAPTURE_ERROR_AUD_OUT_FILE), ResStr(IDS_CAPTURE_ERROR), MB_ICONERROR | MB_OK);
				return;
			}
		}

		m_pVidBuffer = m_fVidOutput && m_nVidBuffers > 0 && m_muxtype == 0 ? DNew CBufferFilter(nullptr, nullptr) : nullptr;
		if (CComQIPtr<IBufferFilter> pVB = m_pVidBuffer) {
			pVB->SetBuffers(m_nVidBuffers);
			pVB->SetPriority(THREAD_PRIORITY_NORMAL);
		}

		m_pAudBuffer = m_fAudOutput && m_nAudBuffers > 0 && m_muxtype == 0 ? DNew CBufferFilter(nullptr, nullptr) : nullptr;
		if (CComQIPtr<IBufferFilter> pAB = m_pAudBuffer) {
			pAB->SetBuffers(m_nAudBuffers);
			pAB->SetPriority(THREAD_PRIORITY_ABOVE_NORMAL);
		}

		EnableControls(this, false);

		m_pMainFrame->StartCapture();

		m_nRecordTimerID = SetTimer(1, 100, nullptr);
	} else {
		KillTimer(m_nRecordTimerID);
		m_nRecordTimerID = 0;

		m_pMainFrame->StopCapture();
		EnableControls(this, true);

		m_pVidBuffer = nullptr;
		m_pAudBuffer = nullptr;
	}
}

void CPlayerCaptureDialog::OnChangeVideoBuffers()
{
	UpdateData();
	AfxGetProfile().WriteInt(IDS_R_CAPTURE, L"VidBuffers", std::max(m_nVidBuffers, 0));
}

void CPlayerCaptureDialog::OnChangeAudioBuffers()
{
	UpdateData();
	AfxGetProfile().WriteInt(IDS_R_CAPTURE, L"AudBuffers", std::max(m_nAudBuffers, 0));
}

void CPlayerCaptureDialog::OnTimer(UINT_PTR nIDEvent)
{
	if (nIDEvent == m_nRecordTimerID) {
		if (m_pMainFrame->m_fCapturing) {
			ULARGE_INTEGER FreeBytesAvailable, TotalNumberOfBytes, TotalNumberOfFreeBytes;
			if (GetDiskFreeSpaceExW(m_file.Left(m_file.ReverseFind('\\')+1), &FreeBytesAvailable, &TotalNumberOfBytes, &TotalNumberOfFreeBytes)
					&& FreeBytesAvailable.QuadPart < 1024i64*1024*10) {
				OnRecord();
			}
		}
	} else {
		__super::OnTimer(nIDEvent);
	}
}

void CPlayerCaptureDialog::OnBnClickedVidAudPreview()
{
	UpdateData();
	UpdateGraph();
}

void CPlayerCaptureDialog::OnBnClickedAudioToWav()
{
	//UpdateMuxer();
}

void CPlayerCaptureDialog::OnChangeFileType()
{
	UpdateData();

	CString ext = m_file.Mid(m_file.ReverseFind('.')+1).MakeLower();

	if (m_muxtype == 0 && ext != L"avi") {
		m_file = m_file.Left(m_file.GetLength()-4) + L".avi";
	} else if (m_muxtype == 1 && ext != L"mkv") {
		m_file = m_file.Left(m_file.GetLength()-4) + L".mkv";
	} else if (m_muxtype == 2 && ext != L"dsm") {
		m_file = m_file.Left(m_file.GetLength()-4) + L".dsm";
	}

	UpdateData(FALSE);

	GetDlgItem(IDC_EDIT5)->EnableWindow(m_muxtype == 0);
	GetDlgItem(IDC_EDIT6)->EnableWindow(m_muxtype == 0);
}
