/*
 * (C) 2017-2018 see Authors.txt
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
#include <MMReg.h>
#include "SampleFormat.h"
#include "AudioDecoders.h"

void bswap16_buf(uint16_t* dst16, const uint16_t* src16, unsigned len)
{
	while (len--) {
		*dst16++ = _byteswap_ushort(*src16++);
	}
}

void dvdlpcm20_to_pcm32(uint32_t* dst32, const uint8_t* src, unsigned blocks, const unsigned channels)
{
	while (blocks--) {
		const uint8_t* b = src + channels * 4;
		for (unsigned i = 0; i < channels; ++i) {
			*dst32++ = (src[0] << 24) | (src[1] << 16) | ((*b & 0xF0) << 8);
			*dst32++ = (src[2] << 24) | (src[3] << 16) | ((*b & 0x0F) << 12);
			src += 4;
			b++;
		}
		src = b;
	}
}

void dvdlpcm24_to_pcm32(uint32_t* dst32, const uint8_t* src, unsigned blocks, const unsigned channels)
{
	while (blocks--) {
		const uint8_t* b = src + channels * 4;
		for (unsigned i = 0; i < channels; ++i) {
			*dst32++ = (src[0] << 24) | (src[1] << 16) | (*b++ << 8);
			*dst32++ = (src[2] << 24) | (src[3] << 16) | (*b++ << 8);
			src += 4;
		}
		src = b;
	}
}

std::unique_ptr<BYTE[]> DecodeDvdLPCM(unsigned& dst_size, SampleFormat& dst_sf, BYTE* src, unsigned& src_size, const unsigned channels, const unsigned bitdepth)
{
	// https://wiki.multimedia.cx/index.php/PCM#DVD_PCM

	const unsigned blocksize = channels * 2 * bitdepth / 8;
	if (!blocksize || blocksize > src_size) {
		return nullptr;
	}

	const unsigned blocks = src_size / blocksize;
	const unsigned allsamples = blocks * 2 * channels;

	dst_size = allsamples * (bitdepth <= 16 ? 2 : 4); // convert to 16 and 32-bit
	std::unique_ptr<BYTE[]> dst(new(std::nothrow) BYTE[dst_size]);
	if (!dst) {
		return nullptr;
	}

	if (bitdepth == 16) {
		bswap16_buf((uint16_t*)dst.get(), (uint16_t*)src, allsamples);
		dst_sf = SAMPLE_FMT_S16;
	}
	else if (bitdepth == 20) {
		dvdlpcm20_to_pcm32((uint32_t*)dst.get(), src, blocks, channels);
		dst_sf = SAMPLE_FMT_S32;
	}
	else if (bitdepth == 24) {
		dvdlpcm24_to_pcm32((uint32_t*)dst.get(), src, blocks, channels);
		dst_sf = SAMPLE_FMT_S32;
	}

	src_size %= blocksize;

	return dst;
}

std::unique_ptr<BYTE[]> DecodeDvdaLPCM(unsigned& dst_size, SampleFormat& dst_sf, BYTE* src, unsigned& src_size, const DVDA_INFO& a)
{
	const unsigned raw_group1_size = a.channels1 * a.bitdepth1 / 4;
	const unsigned raw_group2_size = a.channels2 * a.bitdepth2 / 4;
	const unsigned raw_group2_factor = a.samplerate1 / a.samplerate2;
	const unsigned blocksize = raw_group1_size + raw_group2_size / raw_group2_factor;

	if (!blocksize || blocksize > src_size) {
		return nullptr;
	}

	unsigned blocks = src_size / blocksize;
	const unsigned channels = a.channels1 + a.channels2;
	const unsigned allsamples = blocks * 2 * channels;

	dst_size = allsamples * (a.bitdepth1 <= 16 ? 2 : 4); // convert to 16 and 32-bit
	std::unique_ptr<BYTE[]> dst(new(std::nothrow) BYTE[dst_size]);
	if (!dst) {
		return nullptr;
	}

	if (a.bitdepth1 == a.bitdepth2 && a.samplerate1 == a.samplerate2) {
		if (a.bitdepth1 == 16) {
			uint16_t* src16 = (uint16_t*)src;
			uint16_t* dst_1 = (uint16_t*)dst.get();
			uint16_t* dst_2 = dst_1 + a.channels1;

			while (blocks--) {
				for (unsigned i = 0; i < a.channels2; ++i) {
					dst_2[i]            = _byteswap_ushort(*src16++);
					dst_2[i + channels] = _byteswap_ushort(*src16++);
				}
				for (unsigned i = 0; i < a.channels1; ++i) {
					dst_1[i]            = _byteswap_ushort(*src16++);
					dst_1[i + channels] = _byteswap_ushort(*src16++);
				}
				dst_1 += 2 * channels;
				dst_2 = dst_1 + a.channels1;
			}
			dst_sf = SAMPLE_FMT_S16;
		}
		else {
			uint32_t* dst_1 = (uint32_t*)dst.get();
			uint32_t* dst_2 = dst_1 + a.channels1;

			if (a.bitdepth1 == 20) {
				while (blocks--) {
					uint8_t* b = src + a.channels2 * 4;
					for (unsigned i = 0; i < a.channels2; ++i) {
						dst_2[i]            = (src[0] << 24) | (src[1] << 16) | ((*b & 0xF0) << 8);
						dst_2[i + channels] = (src[2] << 24) | (src[3] << 16) | ((*b & 0x0F) << 12);
						src += 4;
						b++;
					}
					src = b;
					b = src + a.channels1 * 4;
					for (unsigned i = 0; i < a.channels1; ++i) {
						dst_1[i]            = (src[0] << 24) | (src[1] << 16) | ((*b & 0xF0) << 8);
						dst_1[i + channels] = (src[2] << 24) | (src[3] << 16) | ((*b & 0x0F) << 12);
						src += 4;
						b++;
					}
					src = b;
					dst_1 += 2 * channels;
					dst_2 = dst_1 + a.channels1;
				}
			}
			else if (a.bitdepth1 == 24) {
				while (blocks--) {
					uint8_t* b = src + a.channels2 * 4;
					for (unsigned i = 0; i < a.channels2; ++i) {
						dst_2[i]            = (src[0] << 24) | (src[1] << 16) | (*b++ << 8);
						dst_2[i + channels] = (src[2] << 24) | (src[3] << 16) | (*b++ << 8);
						src += 4;
					}
					src = b;
					b = src + a.channels1 * 4;
					for (unsigned i = 0; i < a.channels1; ++i) {
						dst_1[i]            = (src[0] << 24) | (src[1] << 16) | (*b++ << 8);
						dst_1[i + channels] = (src[2] << 24) | (src[3] << 16) | (*b++ << 8);
						src += 4;
					}
					src = b;
					dst_1 += 2 * channels;
					dst_2 = dst_1 + a.channels1;
				}
			}
			dst_sf = SAMPLE_FMT_S32;
		}
	}
	// channels assigned to group 2 have a lower samplerate/bit-depth than the channels in group 1
	else {
		uint8_t pcm_group1_pack[2 * 4 * sizeof(int32_t)];
		uint8_t pcm_group2_pack[2 * 4 * sizeof(int32_t)];

		const unsigned pcm_group1_size = 2 * a.channels1 * sizeof(int32_t);
		const unsigned pcm_group2_size = 2 * a.channels2 * sizeof(int32_t);

		uint8_t* data = dst.get();
		uint8_t* buf_out = data;
		uint8_t* buf = src;
		uint8_t* buf_inp = buf;

		unsigned raw_group2_index = 0;

		while (buf_inp + raw_group1_size + (raw_group2_index == 0 ? raw_group2_size : 0) <= buf + src_size) {
			int pcm_byte_index;
			pcm_byte_index = 0;
			if (raw_group2_index == 0) {
				for (unsigned i = 0; i < 2 * a.channels2; i++) {
					switch (a.bitdepth2) {
					case 16:
						if (a.bitdepth1 > 16) {
							pcm_group2_pack[pcm_byte_index++] = 0;
							pcm_group2_pack[pcm_byte_index++] = 0;
						}
						pcm_group2_pack[pcm_byte_index++] = buf_inp[2 * i + 1];
						pcm_group2_pack[pcm_byte_index++] = buf_inp[2 * i];
						break;
					case 20:
						pcm_group2_pack[pcm_byte_index++] = 0;
						if (i % 2)
							pcm_group2_pack[pcm_byte_index++] = buf_inp[4 * a.channels2 + i / 2] & 0x0f;
						else
							pcm_group2_pack[pcm_byte_index++] = buf_inp[4 * a.channels2 + i / 2] >> 4;
						pcm_group2_pack[pcm_byte_index++] = buf_inp[2 * i + 1];
						pcm_group2_pack[pcm_byte_index++] = buf_inp[2 * i];
						break;
					case 24:
						pcm_group2_pack[pcm_byte_index++] = 0;
						pcm_group2_pack[pcm_byte_index++] = buf_inp[4 * a.channels2 + i];
						pcm_group2_pack[pcm_byte_index++] = buf_inp[2 * i + 1];
						pcm_group2_pack[pcm_byte_index++] = buf_inp[2 * i];
						break;
					default:
						break;
					}
				}
				buf_inp += raw_group2_size;
			}
			raw_group2_index++;
			if (raw_group2_index == raw_group2_factor) {
				raw_group2_index = 0;
			}
			pcm_byte_index = 0;
			for (unsigned i = 0; i < 2 * a.channels1; i++) {
				switch (a.bitdepth1) {
				case 16:
					pcm_group1_pack[pcm_byte_index++] = buf_inp[2 * i + 1];
					pcm_group1_pack[pcm_byte_index++] = buf_inp[2 * i];
					break;
				case 20:
					pcm_group1_pack[pcm_byte_index++] = 0;
					if (i % 2)
						pcm_group1_pack[pcm_byte_index++] = buf_inp[4 * a.channels1 + i / 2] << 4;
					else
						pcm_group1_pack[pcm_byte_index++] = buf_inp[4 * a.channels1 + i / 2] & 0xf0;
					pcm_group1_pack[pcm_byte_index++] = buf_inp[2 * i + 1];
					pcm_group1_pack[pcm_byte_index++] = buf_inp[2 * i];
					break;
				case 24:
					pcm_group1_pack[pcm_byte_index++] = 0;
					pcm_group1_pack[pcm_byte_index++] = buf_inp[4 * a.channels1 + i];
					pcm_group1_pack[pcm_byte_index++] = buf_inp[2 * i + 1];
					pcm_group1_pack[pcm_byte_index++] = buf_inp[2 * i];
					break;
				default:
					break;
				}
			}
			buf_inp += raw_group1_size;
			memcpy(buf_out, pcm_group1_pack, pcm_group1_size / 2);
			buf_out += pcm_group1_size / 2;
			memcpy(buf_out, pcm_group2_pack, pcm_group2_size / 2);
			buf_out += pcm_group2_size / 2;
			memcpy(buf_out, pcm_group1_pack + pcm_group1_size / 2, pcm_group1_size / 2);
			buf_out += pcm_group1_size / 2;
			memcpy(buf_out, pcm_group2_pack + pcm_group2_size / 2, pcm_group2_size / 2);
			buf_out += pcm_group2_size / 2;
		}
		dst_sf = SAMPLE_FMT_S32;
	}

	if (a.groupassign >= 18) {
		unsigned last = (a.groupassign == 20) ? 5 : 4;

		if (a.bitdepth1 == 16) {
			uint16_t* dst16 = (uint16_t*)dst.get();
			for (unsigned i = 0; i < allsamples; i += channels) {
				std::swap(dst16[i + 2], dst16[i + 4]);
				std::swap(dst16[i + 3], dst16[i + last]);
			}
		} else {
			uint32_t* dst32 = (uint32_t*)dst.get();
			for (unsigned i = 0; i < allsamples; i += channels) {
				std::swap(dst32[i + 2], dst32[i + 4]);
				std::swap(dst32[i + 3], dst32[i + last]);
			}
		}
	}

	src_size %= blocksize;

	return dst;
}

std::unique_ptr<BYTE[]> DecodeHdmvLPCM(unsigned& dst_size, SampleFormat& dst_sf, BYTE* src, unsigned& src_size, const unsigned channels, const unsigned bitdepth, const BYTE channel_conf)
{
	const unsigned framesize = ((channels + 1) & ~1) * ((bitdepth + 7) / 8);
	if (!framesize) {
		return nullptr;
	}
	const unsigned frames = src_size / framesize;

	dst_size = frames * channels * (bitdepth <= 16 ? 2 : 4); // convert to 16 and 32-bit
	std::unique_ptr<BYTE[]> dst(new(std::nothrow) BYTE[dst_size]);
	if (!dst) {
		return nullptr;
	}

	auto& remap = s_scmap_hdmv[channel_conf].ch;

	if (bitdepth == 16) {
		uint16_t* dst16 = (uint16_t*)dst.get();

		for (unsigned i = 0; i < frames; ++i) {
			uint16_t* src16 = (uint16_t*)src;
			for (unsigned j = 0; j < channels; ++j) {
				*(dst16++) = _byteswap_ushort(src16[remap[j]]);
			}
			src += framesize;
		}
		dst_sf = SAMPLE_FMT_S16;
	}
	else if (bitdepth == 20 || bitdepth == 24) {
		uint32_t* dst32 = (uint32_t*)dst.get(); // convert to 32-bit

		for (unsigned i = 0; i < frames; i++) {
			for (unsigned j = 0; j < channels; j++) {
				unsigned n = remap[j] * 3;
				*(dst32++) = (src[n] << 24) | (src[n + 1] << 16) | (src[n + 2] << 8);
			}
			src += framesize;
		}
		dst_sf = SAMPLE_FMT_S32;
	}

	src_size %= framesize;

	return dst;
}
