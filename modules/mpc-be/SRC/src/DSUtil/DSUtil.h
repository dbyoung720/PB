/*
 * (C) 2003-2006 Gabest
 * (C) 2006-2020 see Authors.txt
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

#pragma once

#include <vector>
#include <list>
#include <BaseClasses/streams.h>
#include "H264Nalu.h"
#include "MediaTypeEx.h"
#include "MFCHelper.h"
#include "text.h"
#include "Log.h"
#include <basestruct.h>
#include <mpc_defines.h>
#include "Utils.h"

#define LCID_NOSUBTITLES    -1

#define SAFE_RELEASE(p)      { if (p) { (p)->Release(); (p) = nullptr; } }
#define SAFE_CLOSE_HANDLE(p) { if (p) { if ((p) != INVALID_HANDLE_VALUE) VERIFY(CloseHandle(p)); (p) = nullptr; } }

#define EXIT_ON_ERROR(hres)  { if (FAILED(hres)) return hres; }

#define IsWaveFormatExtensible(wfe) (wfe->wFormatTag == WAVE_FORMAT_EXTENSIBLE && wfe->cbSize == 22)

#define QI(i)  (riid == __uuidof(i)) ? GetInterface((i*)this, ppv) :
#define QI2(i) (riid == IID_##i) ? GetInterface((i*)this, ppv) :

//#ifndef _countof
//#define _countof(array) (sizeof(array)/sizeof(array[0]))
//#endif

extern int				CountPins(IBaseFilter* pBF, int& nIn, int& nOut, int& nInC, int& nOutC);
extern bool				IsSplitter(IBaseFilter* pBF, bool fCountConnectedOnly = false);
extern bool				IsMultiplexer(IBaseFilter* pBF, bool fCountConnectedOnly = false);
extern bool				IsStreamStart(IBaseFilter* pBF);
extern bool				IsStreamEnd(IBaseFilter* pBF);
extern bool				IsVideoDecoder(IBaseFilter* pBF, bool fCountConnectedOnly = false);
extern bool				IsVideoRenderer(IBaseFilter* pBF);
extern bool				IsVideoRenderer(const CLSID clsid);
extern bool				IsAudioWaveRenderer(IBaseFilter* pBF);

extern IBaseFilter*		GetUpStreamFilter(IBaseFilter* pBF, IPin* pInputPin = nullptr);
extern IPin*			GetUpStreamPin(IBaseFilter* pBF, IPin* pInputPin = nullptr);
extern IBaseFilter*		GetDownStreamFilter(IBaseFilter* pBF, IPin* pInputPin = nullptr);
extern IPin*			GetDownStreamPin(IBaseFilter* pBF, IPin* pInputPin = nullptr);
extern IPin*			GetFirstPin(IBaseFilter* pBF, PIN_DIRECTION dir = PINDIR_INPUT);
extern IPin*			GetFirstDisconnectedPin(IBaseFilter* pBF, PIN_DIRECTION dir);
extern void				NukeDownstream(IBaseFilter* pBF, IFilterGraph* pFG);
extern void				NukeDownstream(IPin* pPin, IFilterGraph* pFG);
extern IBaseFilter*		FindFilter(LPCWSTR clsid, IFilterGraph* pFG);
extern IBaseFilter*		FindFilter(const CLSID& clsid, IFilterGraph* pFG);
extern IPin*			FindPin(IBaseFilter* pBF, PIN_DIRECTION direction, const AM_MEDIA_TYPE* pRequestedMT);
extern IPin*			FindPin(IBaseFilter* pBF, PIN_DIRECTION direction, const GUID majortype);
extern CString			GetFilterName(IBaseFilter* pBF);
extern CString			GetPinName(IPin* pPin);
extern IFilterGraph*	GetGraphFromFilter(IBaseFilter* pBF);
extern IBaseFilter*		GetFilterFromPin(IPin* pPin);
extern IPin*			AppendFilter(IPin* pPin, CString DisplayName, IGraphBuilder* pGB);
extern IBaseFilter*		AppendFilter(IPin* pPin, IMoniker* pMoniker, IGraphBuilder* pGB);
extern IPin*			InsertFilter(IPin* pPin, CString DisplayName, IGraphBuilder* pGB);
extern bool				CreateFilter(CString DisplayName, IBaseFilter** ppBF, CString& FriendlyName);
extern bool				HasMediaType(IFilterGraph *pFilterGraph, const GUID &mediaType);

extern void				ExtractMediaTypes(IPin* pPin, std::vector<GUID>& types);
extern void				ExtractMediaTypes(IPin* pPin, std::list<CMediaType>& mts);
extern bool				ExtractBIH(const AM_MEDIA_TYPE* pmt, BITMAPINFOHEADER* bih);
extern bool				ExtractBIH(IMediaSample* pMS, BITMAPINFOHEADER* bih);
extern bool				ExtractAvgTimePerFrame(const AM_MEDIA_TYPE* pmt, REFERENCE_TIME& rtAvgTimePerFrame);
extern bool				ExtractDim(const AM_MEDIA_TYPE* pmt, int& w, int& h, int& arx, int& ary);

extern CLSID			GetCLSID(IBaseFilter* pBF);
extern CLSID			GetCLSID(IPin* pPin);

extern void				ShowPPage(CString DisplayName, HWND hParentWnd);
extern void				ShowPPage(IUnknown* pUnknown, HWND hParentWnd);

extern bool				IsCLSIDRegistered(LPCWSTR clsid);
extern bool				IsCLSIDRegistered(const CLSID& clsid);

// return S_OK if installed and available, S_FALSE if installed but not available, E_FAIL if not installed
extern HRESULT			CheckFilterCLSID(const CLSID& clsid);

extern void				CStringToBin(CString str, std::vector<BYTE>& data);
extern CString			BinToCString(const BYTE* ptr, size_t len);

enum cdrom_t {
	CDROM_NotFound,
	CDROM_Audio,
	CDROM_VideoCD,
	CDROM_DVDVideo,
	CDROM_BDVideo,
	CDROM_DVDAudio,
	CDROM_Unknown
};
extern cdrom_t			GetCDROMType(WCHAR drive, std::list<CString>& files);
extern CString			GetDriveLabel(WCHAR drive);

extern DVD_HMSF_TIMECODE	RT2HMSF(REFERENCE_TIME rt, double fps = 0); // use to remember the current position
extern DVD_HMSF_TIMECODE	RT2HMS_r(REFERENCE_TIME rt);                // use only for information (for display on the screen)
extern REFERENCE_TIME		HMSF2RT(DVD_HMSF_TIMECODE hmsf, double fps = 0);
extern CString				ReftimeToString(const REFERENCE_TIME& rtVal);  // hour, minute, second, millisec
extern CString				ReftimeToString2(const REFERENCE_TIME& rtVal); // hour, minute, second (round)
extern CString				DVDtimeToString(const DVD_HMSF_TIMECODE& rtVal, bool bAlwaysShowHours=false);
extern REFERENCE_TIME		StringToReftime(LPCWSTR strVal);
extern REFERENCE_TIME		StringToReftime2(LPCWSTR strVal);

extern void				memsetd(void* dst, unsigned int c, size_t nbytes);
extern void				memsetw(void* dst, unsigned short c, size_t nbytes);

extern CString			GetFriendlyName(CString DisplayName);
extern HRESULT			LoadExternalObject(LPCWSTR path, REFCLSID clsid, REFIID iid, void** ppv);
extern HRESULT			LoadExternalFilter(LPCWSTR path, REFCLSID clsid, IBaseFilter** ppBF);
extern HRESULT			LoadExternalPropertyPage(IPersist* pP, REFCLSID clsid, IPropertyPage** ppPP);
extern void				UnloadExternalObjects();

extern CString			MakeFullPath(LPCWSTR path);
// simple file system path detector
extern bool				IsLikelyFilePath(const CString &str);

extern GUID				GUIDFromCString(CString str);
extern HRESULT			GUIDFromCString(CString str, GUID& guid);
extern CStringW			CStringFromGUID(const GUID& guid);

extern CString			ISO6391ToLanguage(LPCSTR code);
extern CString			ISO6392ToLanguage(LPCSTR code);

extern bool				IsISO639Language(LPCSTR code);
extern CString			ISO639XToLanguage(LPCSTR code, bool bCheckForFullLangName = false);
extern LCID				ISO6391ToLcid(LPCSTR code);
extern LCID				ISO6392ToLcid(LPCSTR code);
extern CString			ISO6391To6392(LPCSTR code);
extern CString			ISO6392To6391(LPCSTR code);
extern CString			LanguageToISO6392(LPCWSTR lang);

extern bool				DeleteRegKey(LPCWSTR pszKey, LPCWSTR pszSubkey);
extern bool				SetRegKeyValue(LPCWSTR pszKey, LPCWSTR pszSubkey, LPCWSTR pszValueName, LPCWSTR pszValue);
extern bool				SetRegKeyValue(LPCWSTR pszKey, LPCWSTR pszSubkey, LPCWSTR pszValue);

extern void				RegisterSourceFilter(const CLSID& clsid, const GUID& subtype2, LPCWSTR chkbytes, LPCWSTR ext = nullptr, ...);
extern void				RegisterSourceFilter(const CLSID& clsid, const GUID& subtype2, const std::list<CString>& chkbytes, LPCWSTR ext = nullptr, ...);
extern void				UnRegisterSourceFilter(const GUID& subtype);

extern CString			GetDXVAMode(const GUID& guidDecoder);

extern void				TraceFilterInfo(IBaseFilter* pBF);
extern void				TracePinInfo(IPin* pPin);

extern void				SetThreadName(DWORD dwThreadID, LPCSTR szThreadName);

extern void				getExtraData(const BYTE *format, const GUID *formattype, const ULONG formatlen, BYTE *extra, unsigned int *extralen);

extern int				MakeAACInitData(BYTE* pData, int profile, int freq, int channels);
extern bool				MakeMPEG2MediaType(CMediaType& mt, BYTE* seqhdr, DWORD len, int w, int h);
extern HRESULT			CreateMPEG2VIfromAVC(CMediaType* mt, BITMAPINFOHEADER* pbmi, REFERENCE_TIME AvgTimePerFrame, CSize aspect, BYTE* extra, size_t extralen);
extern HRESULT			CreateMPEG2VIfromMVC(CMediaType* mt, BITMAPINFOHEADER* pbmi, REFERENCE_TIME AvgTimePerFrame, CSize aspect, BYTE* extra, size_t extralen);
extern HRESULT			CreateMPEG2VISimple(CMediaType* mt, BITMAPINFOHEADER* pbmi, REFERENCE_TIME AvgTimePerFrame, CSize aspect, BYTE* extra, size_t extralen, DWORD dwProfile = 0, DWORD dwLevel = 0, DWORD dwFlags = 0);
extern HRESULT			CreateAVCfromH264(CMediaType* mt);

extern void				CreateVorbisMediaType(CMediaType& mt, std::vector<CMediaType>& mts, DWORD Channels, DWORD SamplesPerSec, DWORD BitsPerSample, const BYTE* pData, size_t Count);

extern CStringA			VobSubDefHeader(int w, int h, CStringA palette = "");
extern void				CorrectWaveFormatEx(CMediaType& mt);

extern inline const LONGLONG GetPerfCounter();

class CPinInfo : public PIN_INFO
{
public:
	CPinInfo() { pFilter = nullptr; }
	~CPinInfo() { if (pFilter) { pFilter->Release(); } }
};

class CFilterInfo : public FILTER_INFO
{
public:
	CFilterInfo() { pGraph = nullptr; }
	~CFilterInfo() { if (pGraph) { pGraph->Release(); } }
};

#define BeginEnumFilters(pFilterGraph, pEnumFilters, pBaseFilter) \
	{CComPtr<IEnumFilters> pEnumFilters; \
	if (pFilterGraph && SUCCEEDED(pFilterGraph->EnumFilters(&pEnumFilters))) \
	{ \
		for (CComPtr<IBaseFilter> pBaseFilter; S_OK == pEnumFilters->Next(1, &pBaseFilter, 0); pBaseFilter = nullptr) \
		{ \

#define EndEnumFilters }}}

#define BeginEnumCachedFilters(pGraphConfig, pEnumFilters, pBaseFilter) \
	{CComPtr<IEnumFilters> pEnumFilters; \
	if (pGraphConfig && SUCCEEDED(pGraphConfig->EnumCacheFilter(&pEnumFilters))) \
	{ \
		for (CComPtr<IBaseFilter> pBaseFilter; S_OK == pEnumFilters->Next(1, &pBaseFilter, 0); pBaseFilter = nullptr) \
		{ \

#define EndEnumCachedFilters }}}

#define BeginEnumPins(pBaseFilter, pEnumPins, pPin) \
	{CComPtr<IEnumPins> pEnumPins; \
	if (pBaseFilter && SUCCEEDED(pBaseFilter->EnumPins(&pEnumPins))) \
	{ \
		for (CComPtr<IPin> pPin; S_OK == pEnumPins->Next(1, &pPin, 0); pPin = nullptr) \
		{ \

#define EndEnumPins }}}

#define BeginEnumMediaTypes(pPin, pEnumMediaTypes, pMediaType) \
	{CComPtr<IEnumMediaTypes> pEnumMediaTypes; \
	if (pPin && SUCCEEDED(pPin->EnumMediaTypes(&pEnumMediaTypes))) \
	{ \
		AM_MEDIA_TYPE* pMediaType = nullptr; \
		for (; S_OK == pEnumMediaTypes->Next(1, &pMediaType, nullptr); DeleteMediaType(pMediaType), pMediaType = nullptr) \
		{ \

#define EndEnumMediaTypes(pMediaType) } if (pMediaType) DeleteMediaType(pMediaType); }}

#define BeginEnumSysDev(clsid, pMoniker) \
	{CComPtr<ICreateDevEnum> pDevEnum4$##clsid; \
	pDevEnum4$##clsid.CoCreateInstance(CLSID_SystemDeviceEnum); \
	CComPtr<IEnumMoniker> pClassEnum4$##clsid; \
	if (SUCCEEDED(pDevEnum4$##clsid->CreateClassEnumerator(clsid, &pClassEnum4$##clsid, 0)) \
	&& pClassEnum4$##clsid) \
	{ \
		for (CComPtr<IMoniker> pMoniker; pClassEnum4$##clsid->Next(1, &pMoniker, 0) == S_OK; pMoniker = nullptr) \
		{ \

#define EndEnumSysDev }}}

template <typename T> __inline void INITDDSTRUCT(T& dd)
{
	ZeroMemory(&dd, sizeof(dd));
	dd.dwSize = sizeof(dd);
}

template <class T>
static CUnknown* WINAPI CreateInstance(LPUNKNOWN lpunk, HRESULT* phr)
{
	*phr = S_OK;
	CUnknown* punk = new(std::nothrow) T(lpunk, phr);
	if (punk == nullptr) {
		*phr = E_OUTOFMEMORY;
	}
	return punk;
}

namespace CStringUtils
{
	struct IgnoreCaseLess {
		bool operator()(const CString& str1, const CString& str2) const {
			return str1.CompareNoCase(str2) < 0;
		}
	};
	struct LogicalLess {
		bool operator()(const CString& str1, const CString& str2) const {
			return StrCmpLogicalW(str1, str2) < 0;
		}
	};
}
