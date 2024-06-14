// BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
//
// Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
//
// This program is free software; you can redistribute it and/or modify it under the
// terms of the GNU Lesser General Public License as published by the Free Software
// Foundation; either version 3.0 of the License, or (at your option) any later
// version.
//
// Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along
// with Greenlight; if not, see <http://www.gnu.org/licenses/>.

import { createEvent } from "ics";
import { saveAs } from "file-saver";


const createICSContent = (name, room_name, url, voice_bridge, voice_bridge_phone_number, t, use_html) => {
  if (use_html) {
    return createICSWithHtml(name, room_name, url, voice_bridge, voice_bridge_phone_number, t);
  } else {
    return createICSWithoutHTML(name, room_name, url, voice_bridge, voice_bridge_phone_number, t);
  }
}

const createICSWithoutHTML = (name, room_name, url, voice_bridge, voice_bridge_phone_number, t) => {
  let description = `\n\n${t('room.meeting.invite_to_meeting', { name })}\n\n${t('room.meeting.join_by_url')}:\n${url}\n`;

  if (typeof voice_bridge !== 'undefined' || typeof voice_bridge_phone_number !== 'undefined') {
    description += `\n${t('room.meeting.join_by_phone')}: ${voice_bridge_phone_number},,${voice_bridge}\nPIN: ${voice_bridge}`;
  }

  const date = new Date();

  return {
    start: [date.getFullYear(), date.getMonth() + 1, date.getDate(), 12, 0],
    url: url,
    description: description,
    title: room_name,
    location: t('room.meeting.location')
  };
}

const createICSWithHtml = (name, room_name, url, voice_bridge, voice_bridge_phone_number, t) => {
  let phone_data = "";

  if (typeof voice_bridge !== 'undefined' && typeof voice_bridge_phone_number !== 'undefined') {
    phone_data = `<h6 style="padding-top: 0; padding-bottom: 0; font-weight: 500; vertical-align: baseline; font-size: 16px; line-height: 19.2px; margin: 0;" align="left">${t('room.meeting.join_by_phone')}:</h6>
        <p style="line-height: 24px; font-size: 16px; width: 100%; margin: 0;" align="left">${voice_bridge_phone_number},,${voice_bridge}</p>`;
  }

  const HTML = `
  <head>
    <meta http-equiv="x-ua-compatible" content="ie=edge">
    <meta name="x-apple-disable-message-reformatting">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="format-detection" content="telephone=no, date=no, address=no, email=no">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <style type="text/css">
      body,table,td{font-family:Helvetica,Arial,sans-serif !important}.ExternalClass{width:100%}.ExternalClass,.ExternalClass p,.ExternalClass span,.ExternalClass font,.ExternalClass td,.ExternalClass div{line-height:150%}a{text-decoration:none}*{color:inherit}a[x-apple-data-detectors],u+#body a,#MessageViewBody a{color:inherit;text-decoration:none;font-size:inherit;font-family:inherit;font-weight:inherit;line-height:inherit}img{-ms-interpolation-mode:bicubic}table:not([class^=s-]){font-family:Helvetica,Arial,sans-serif;mso-table-lspace:0pt;mso-table-rspace:0pt;border-spacing:0px;border-collapse:collapse}table:not([class^=s-]) td{border-spacing:0px;border-collapse:collapse}@media screen and (max-width: 600px){.w-full,.w-full>tbody>tr>td{width:100% !important}*[class*=s-lg-]>tbody>tr>td{font-size:0 !important;line-height:0 !important;height:0 !important}.s-5>tbody>tr>td{font-size:20px !important;line-height:20px !important;height:20px !important}}
    </style>
  </head>
  <body style="outline: 0; width: 100%; min-width: 100%; height: 100%; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; font-family: Helvetica, Arial, sans-serif; line-height: 24px; font-weight: normal; font-size: 16px; -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box; color: #000000; margin: 0; padding: 0; border-width: 0;" bgcolor="#ffffff">
    <table class="body" valign="top" role="presentation" border="0" cellpadding="0" cellspacing="0" style="outline: 0; width: 100%; min-width: 100%; height: 100%; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; font-family: Helvetica, Arial, sans-serif; line-height: 24px; font-weight: normal; font-size: 16px; -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box; color: #000000; margin: 0; padding: 0; border-width: 0;" bgcolor="#ffffff">
      <tbody>
        <tr>
          <td valign="top" style="line-height: 24px; font-size: 16px; margin: 0;" align="left">
            <div>
              <p style="line-height: 24px; font-size: 16px; width: 100%; margin: 0;" align="left"></p>
            </div>
            <table class="container-fluid" role="presentation" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
              <tbody>
                <tr>
                  <td style="line-height: 24px; font-size: 16px; width: 100%; margin: 0; padding: 0 16px;" align="left">
                    <table class="s-5 w-full" role="presentation" border="0" cellpadding="0" cellspacing="0" style="width: 100%;" width="100%">
                      <tbody>
                        <tr>
                          <td style="line-height: 20px; font-size: 20px; width: 100%; height: 20px; margin: 0;" align="left" width="100%" height="20">
                            &#160;
                          </td>
                        </tr>
                      </tbody>
                    </table>
                    <table class="hr" role="presentation" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
                      <tbody>
                        <tr>
                          <td style="line-height: 24px; font-size: 16px; border-top-width: 1px; border-top-color: #e2e8f0; border-top-style: solid; height: 1px; width: 100%; margin: 0;" align="left">
                          </td>
                        </tr>
                      </tbody>
                    </table>
                    <table class="s-5 w-full" role="presentation" border="0" cellpadding="0" cellspacing="0" style="width: 100%;" width="100%">
                      <tbody>
                        <tr>
                          <td style="line-height: 20px; font-size: 20px; width: 100%; height: 20px; margin: 0;" align="left" width="100%" height="20">
                            &#160;
                          </td>
                        </tr>
                      </tbody>
                    </table>
                    <h5 style="padding-top: 0; padding-bottom: 0; font-weight: 500; vertical-align: baseline; font-size: 20px; line-height: 24px; margin: 0;" align="left">${t('room.meeting.invite_to_meeting', { name })}</h5>
                    <br>
                    <table class="btn btn-primary" role="presentation" border="0" cellpadding="0" cellspacing="0" style="border-radius: 6px; border-collapse: separate !important;">
                      <tbody>
                        <tr>
                          <td style="line-height: 24px; font-size: 16px; border-radius: 6px; margin: 0;" align="center" bgcolor="#0d6efd">
                            <a href="${url}" style="color: #ffffff; font-size: 16px; font-family: Helvetica, Arial, sans-serif; text-decoration: none; border-radius: 6px; line-height: 20px; display: block; font-weight: normal; white-space: nowrap; background-color: #0d6efd; padding: 8px 12px; border: 1px solid #0d6efd;">${t('room.meeting.join_meeting')}</a>
                          </td>
                        </tr>
                      </tbody>
                    </table>
                    <br>
                    <h5 style="padding-top: 0; padding-bottom: 0; font-weight: 500; vertical-align: baseline; font-size: 20px; line-height: 24px; margin: 0;" align="left">${t('room.meeting.alternative_options')}:</h5>
                    <h6 style="padding-top: 0; padding-bottom: 0; font-weight: 500; vertical-align: baseline; font-size: 16px; line-height: 19.2px; margin: 0;" align="left">${t('room.meeting.join_by_url')}</h6>
                    <p style="line-height: 24px; font-size: 16px; width: 100%; margin: 0;" align="left"><a style="color: #0d6efd;">${url}</a></p>
                    <br>
                    ${phone_data}
                  </td>
                </tr>
              </tbody>
            </table>
          </td>
        </tr>
      </tbody>
    </table>
  </body>`;

  const date = new Date();

  return {
    start: [date.getFullYear(), date.getMonth() + 1, date.getDate(), 12, 0],
    url: url,
    htmlContent: HTML,
    title: room_name,
    location: t('room.meeting.location')
  };
}

export const downloadICS = (name, room, url, voice_bridge, voice_bridge_phone_number, t, use_html) => {
  createEvent(createICSContent(name, room, url, voice_bridge, voice_bridge_phone_number, t, use_html), (error, value) => {
    if (error !== undefined){
      throw new Error('Error creating ICS: ' + error);
    }
    const blob = new Blob([value], { type: "text/plain;charset=utf-8" });
    saveAs(blob, `bbb-meeting-${room.replace(/[/\\?%*:|"<>]/g, '')}.ics`);
  });
};