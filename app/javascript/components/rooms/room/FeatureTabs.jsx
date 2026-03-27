import React, {
  useCallback, useEffect, useMemo, useState,
} from 'react';
import {
  CalendarDaysIcon,
  ChartBarIcon,
  ClockIcon,
  Cog6ToothIcon,
  FolderIcon,
  Squares2X2Icon,
  UserGroupIcon,
} from '@heroicons/react/24/outline';
import { Modal as BootstrapModal } from 'react-bootstrap';
import { useParams, useSearchParams } from 'react-router-dom';
import useSiteSetting from '../../../hooks/queries/site_settings/useSiteSetting';
import useRoomConfigValue from '../../../hooks/queries/rooms/useRoomConfigValue';
import useRoomRecordings from '../../../hooks/queries/recordings/useRoomRecordings';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import axios from '../../../helpers/Axios';
import Presentation from './presentation/Presentation';
import SharedAccess from './shared_access/SharedAccess';
import RoomSettings from './room_settings/RoomSettings';

const ROOM_COPY = {
  en: {
    tabs: {
      overview: 'Overview',
      sessions: 'All Sessions',
      history: 'Past Sessions',
      future: 'Future Sessions',
      files: 'Files',
      access: 'Participants',
      settings: 'Settings',
    },
    common: {
      loading: 'Loading...',
      rows: 'Rows per page',
      prev: 'Prev',
      next: 'Next',
      page: 'Page',
      all: 'All',
      noData: 'No data found.',
      close: 'Close',
    },
    overview: {
      title: 'Operational summary',
      body: 'Use this room as the control point for sessions, files, access, and governance.',
      live: 'Live status',
      attendees: 'Live attendees',
      upcoming: 'Upcoming',
      completed: 'Completed',
      activity: 'Session activity',
      activityEmpty: 'No completed sessions yet.',
      shortcuts: 'Quick links',
      shortcutsBody: 'Jump directly to the room workflows you manage most.',
      goSessions: 'Open all sessions',
      goFuture: 'Plan a future session',
      goHistory: 'Open past sessions',
      goSettings: 'Room settings',
      stateLive: 'Live',
      stateIdle: 'Idle',
    },
    sessions: {
      title: 'All room sessions',
      body: 'Past and future sessions for this room in one table.',
      filters: 'Status filter',
      date: 'Start',
      end: 'End',
      titleCol: 'Session',
      type: 'Type',
      attendees: 'Users',
      duration: 'Duration',
      status: 'Status',
      action: 'Action',
      noData: 'No room sessions found.',
      futureType: 'Future',
      pastType: 'Past',
      open: 'Join',
      startNow: 'Start now',
      viewReport: 'View Report',
      scheduled: 'Scheduled',
      ongoing: 'Ongoing',
      completed: 'Completed',
    },
    history: {
      title: 'Past sessions and recordings',
      body: 'Inspect completed sessions, analytics, exports, and recordings for this room.',
      tabs: {
        meetings: 'Past Sessions',
        recordings: 'Recordings',
      },
      meetingsTitle: 'Past Sessions/Meetings',
      recordingsTitle: "Room's Recordings",
      noMeetings: 'No completed sessions yet.',
      noUsers: 'No user evidence for this meeting.',
      noRecordings: 'No recordings available for this room.',
      date: 'Date',
      meeting: 'Meeting',
      users: 'Users',
      duration: 'Duration',
      attendance: 'Attendance',
      details: 'View Report',
      user: 'User',
      role: 'Role',
      checks: 'Checks',
      analytics: 'Analytics summary',
      participants: 'Participants',
      checksLabel: 'Checks',
      events: 'Events',
      recording: 'Open recording',
      exportExcel: 'Export Excel',
      exportCsv: 'Export CSV',
      exportJson: 'Export JSON',
      ok: 'OK',
      late: 'Late',
      missed: 'Missed',
      loadError: 'Unable to load meeting evidence.',
      recordedAt: 'Recorded At',
      visibility: 'Visibility',
      formats: 'Formats',
      options: 'Options',
      open: 'Open',
      reportTitle: 'Session report',
      reportSubtitle: 'Review engagement, attention, attendance, and evidence for this completed session.',
      attendanceScore: 'Attendance Score',
      attentionScore: 'Attention Score',
      engagementScore: 'Engagement Score',
      activityMetric: 'Activity Score',
      focusRate: 'Focus Rate',
      checkPass: 'Check Pass',
      timelineTitle: 'Engagement Timeline',
      timelineBody: 'Activity distribution and the latest engagement events for this session.',
      noTimeline: 'No engagement timeline available.',
      time: 'Time',
      type: 'Type',
      detail: 'Detail',
      focusBlur: 'Focus / Blur',
      score: 'Score',
      status: 'Status',
      statusStrong: 'Strong',
      statusWatch: 'Watch',
      statusRisk: 'At Risk',
      statusLeftEarly: 'Left Early',
      statusNoEvidence: 'No Evidence',
      userIdLabel: 'User ID',
      joinTime: 'Join',
      leaveTime: 'Leave',
      onlineTime: 'Online Time',
      checksOkLabel: 'ATT OK',
      checksMissedLabel: 'ATT MISSED',
      checksLateLabel: 'Late',
      attendanceTotalLabel: 'ATT Total',
      quizTotalLabel: 'QUIZ Total',
      quizOkLabel: 'QUIZ OK',
      quizNokLabel: 'QUIZ NOK',
      quizLateLabel: 'QUIZ Late',
      quizMissedLabel: 'QUIZ Missed',
      pollAnswers: 'Polls',
      chatMessages: 'Messages',
      raiseHands: 'Hands',
      firstCheck: 'First Check',
      lastCheck: 'Last Check',
      idleActive: 'Idle / Active',
      detailTitle: 'Participant detail',
      detailSubtitle: 'Detailed participation, attention, and attendance evidence for this session.',
      noParticipantDetail: 'No participant detail selected.',
      detailAction: 'Detail',
      attributeName: 'Attribute',
      attributeValue: 'Score / Value',
      nativeTitle: 'Learning Analytics Dashboard (native)',
      nativeBody: 'Native BBB analytics remain available as a deeper companion view.',
      totalUsers: 'Total Users',
      activityScore: 'Activity Score',
      timeline: 'Timeline',
      polls: 'Polls',
      quizzes: 'Quizzes',
      openNative: 'Open Native Analytics',
    },
    future: {
      title: 'Future sessions and scheduling',
      body: 'Manage upcoming sessions scheduled for this room.',
      button: 'Plan Future Session',
      formTitle: 'Plan Future Session',
      titleLabel: 'Title',
      description: 'Description',
      start: 'Start',
      end: 'End',
      timezone: 'Timezone',
      create: 'Create session',
      roomIcs: 'Room ICS',
      scheduleList: 'Upcoming sessions',
      noFuture: 'No future sessions scheduled.',
      startNow: 'Start now',
      cancel: 'Cancel',
      required: 'Title, start, and end are required.',
      created: 'Session created.',
      startedNow: 'Session started now.',
      cancelled: 'Session cancelled.',
      error: 'Scheduling request failed.',
    },
    files: {
      title: 'Room files',
      body: 'Browse your presentation library, shared files, and choose the default file for this room.',
      disabled: 'File uploads are not enabled for this room.',
    },
    access: {
      title: 'Participants',
      body: 'Review the room owner and shared participants for this room.',
      disabled: 'Room sharing is disabled at the platform level.',
    },
    settings: {
      title: 'Room settings',
      body: 'Control room defaults, moderation, access codes, and deletion.',
    },
  },
  tr: {
    tabs: {
      overview: 'Genel Bakis',
      sessions: 'Tum Oturumlar',
      history: 'Gecmis Oturumlar',
      future: 'Gelecek Oturumlar',
      files: 'Dosyalar',
      access: 'Katilimcilar',
      settings: 'Ayarlar',
    },
    common: {
      loading: 'Yukleniyor...',
      rows: 'Satir sayisi',
      prev: 'Geri',
      next: 'Ileri',
      page: 'Sayfa',
      all: 'Tum',
      noData: 'Veri bulunamadi.',
      close: 'Kapat',
    },
    overview: {
      title: 'Operasyon ozet',
      body: 'Bu oda uzerinden oturum, dosya, erisim ve yonetim islemlerini yonetin.',
      live: 'Canli durum',
      attendees: 'Canli katilimci',
      upcoming: 'Planli',
      completed: 'Tamamlanan',
      activity: 'Oturum aktivitesi',
      activityEmpty: 'Tamamlanmis oturum yok.',
      shortcuts: 'Hizli erisim',
      shortcutsBody: 'En sik kullanilan oda akislari icin kisayollar.',
      goSessions: 'Tum oturumlar',
      goFuture: 'Gelecek oturum planla',
      goHistory: 'Gecmis oturumlar',
      goSettings: 'Oda ayarlari',
      stateLive: 'Canli',
      stateIdle: 'Hazir',
    },
    sessions: {
      title: 'Tum oda oturumlari',
      body: 'Bu oda icin gecmis ve gelecek oturumlar tek tabloda.',
      filters: 'Durum filtresi',
      date: 'Baslangic',
      end: 'Bitis',
      titleCol: 'Oturum',
      type: 'Tur',
      attendees: 'Kullanici',
      duration: 'Sure',
      status: 'Durum',
      action: 'Islem',
      noData: 'Bu oda icin oturum bulunamadi.',
      futureType: 'Gelecek',
      pastType: 'Gecmis',
      open: 'Katil',
      startNow: 'Simdi baslat',
      viewReport: 'Raporu Gor',
      scheduled: 'Planli',
      ongoing: 'Devam Eden',
      completed: 'Tamamlandi',
    },
    history: {
      title: 'Gecmis oturumlar ve kayitlar',
      body: 'Bu oda icin tamamlanan oturumlari, raporlari ve kayitlari inceleyin.',
      tabs: {
        meetings: 'Gecmis Oturumlar',
        recordings: 'Kayitlar',
      },
      meetingsTitle: 'Gecmis Oturumlar/Toplantilar',
      recordingsTitle: 'Oda Kayitlari',
      noMeetings: 'Tamamlanmis oturum yok.',
      noUsers: 'Bu toplantida kullanici kaniti yok.',
      noRecordings: 'Bu oda icin kayit yok.',
      date: 'Tarih',
      meeting: 'Toplanti',
      users: 'Kullanici',
      duration: 'Sure',
      attendance: 'Katilim',
      details: 'Raporu Gor',
      user: 'Kullanici',
      role: 'Rol',
      checks: 'Kontrol',
      analytics: 'Analitik ozet',
      participants: 'Katilimci',
      checksLabel: 'Kontrol',
      events: 'Olay',
      recording: 'Kaydi ac',
      exportExcel: 'Excel disa aktar',
      exportCsv: 'CSV disa aktar',
      exportJson: 'JSON disa aktar',
      ok: 'OK',
      late: 'Gec',
      missed: 'Kacirildi',
      loadError: 'Toplanti kanitlari yuklenemedi.',
      recordedAt: 'Kayit Tarihi',
      visibility: 'Gorunurluk',
      formats: 'Formatlar',
      options: 'Secenekler',
      open: 'Ac',
      reportTitle: 'Oturum raporu',
      reportSubtitle: 'Bu tamamlanan oturum icin etkilesim, dikkat, katilim ve kanit ozetini inceleyin.',
      attendanceScore: 'Katilim Skoru',
      attentionScore: 'Dikkat Skoru',
      engagementScore: 'Etkilesim Skoru',
      activityMetric: 'Aktivite Skoru',
      focusRate: 'Odak Orani',
      checkPass: 'Kontrol Basari',
      timelineTitle: 'Etkilesim Zaman Cizelgesi',
      timelineBody: 'Bu oturum icin aktivite dagilimi ve son etkilesim olaylari.',
      noTimeline: 'Etkilesim zaman cizelgesi yok.',
      time: 'Saat',
      type: 'Tur',
      detail: 'Detay',
      focusBlur: 'Odak / Ayrilma',
      score: 'Skor',
      status: 'Durum',
      statusStrong: 'Guclu',
      statusWatch: 'Izle',
      statusRisk: 'Riskli',
      statusLeftEarly: 'Erken Ayrildi',
      statusNoEvidence: 'Kanit Yok',
      userIdLabel: 'Kullanici ID',
      joinTime: 'Giris',
      leaveTime: 'Cikis',
      onlineTime: 'Cevrimici Sure',
      checksOkLabel: 'ATT OK',
      checksMissedLabel: 'ATT MISSED',
      checksLateLabel: 'Gec',
      attendanceTotalLabel: 'ATT Toplam',
      quizTotalLabel: 'QUIZ Toplam',
      quizOkLabel: 'QUIZ OK',
      quizNokLabel: 'QUIZ Basarisiz',
      quizLateLabel: 'QUIZ Gec',
      quizMissedLabel: 'QUIZ Kacirildi',
      pollAnswers: 'Anket',
      chatMessages: 'Mesaj',
      raiseHands: 'El Kaldirma',
      firstCheck: 'Ilk Kontrol',
      lastCheck: 'Son Kontrol',
      idleActive: 'Pasif / Aktif',
      detailTitle: 'Katilimci detayi',
      detailSubtitle: 'Bu oturum icin ayrintili katilim, dikkat ve devam kanitlari.',
      noParticipantDetail: 'Katilimci detayi secilmedi.',
      detailAction: 'Detay',
      attributeName: 'Ozellik',
      attributeValue: 'Skor / Deger',
      nativeTitle: 'Ogrenim Analitigi Paneli (yerel)',
      nativeBody: 'Daha derin BBB analitigi icin yerel gosterge paneli kullanilabilir.',
      totalUsers: 'Toplam Kullanici',
      activityScore: 'Aktivite Skoru',
      timeline: 'Zaman Cizelgesi',
      polls: 'Anket',
      quizzes: 'Quiz',
      openNative: 'Yerel Analitigi Ac',
    },
    future: {
      title: 'Gelecek oturumlar ve planlama',
      body: 'Bu oda icin yaklasan oturumlari yonetin.',
      button: 'Gelecek Oturum Planla',
      formTitle: 'Gelecek Oturum Planla',
      titleLabel: 'Baslik',
      description: 'Aciklama',
      start: 'Baslangic',
      end: 'Bitis',
      timezone: 'Saat dilimi',
      create: 'Oturum olustur',
      roomIcs: 'Oda ICS',
      scheduleList: 'Yaklasan oturumlar',
      noFuture: 'Planli gelecek oturum yok.',
      startNow: 'Simdi baslat',
      cancel: 'Iptal',
      required: 'Baslik, baslangic ve bitis gerekli.',
      created: 'Oturum olusturuldu.',
      startedNow: 'Oturum simdi baslatildi.',
      cancelled: 'Oturum iptal edildi.',
      error: 'Planlama istegi basarisiz.',
    },
    files: {
      title: 'Oda dosyalari',
      body: 'Sunum kutuphanenizi, paylasilan dosyalari inceleyin ve bu oda icin varsayilan dosyayi secin.',
      disabled: 'Bu oda icin dosya yukleme aktif degil.',
    },
    access: {
      title: 'Katilimcilar',
      body: 'Bu oda icin oda sahibini ve paylasilan katilimcilari inceleyin.',
      disabled: 'Platform genelinde oda paylasimi kapali.',
    },
    settings: {
      title: 'Oda ayarlari',
      body: 'Oda varsayimlari, moderasyon, erisim kodlari ve silme islemleri.',
    },
  },
};

function formatDateTime(value, language) {
  if (!value) return '-';

  try {
    return new Intl.DateTimeFormat(
      language === 'tr' ? 'tr-TR' : 'en-US',
      { dateStyle: 'medium', timeStyle: 'short' },
    ).format(new Date(value));
  } catch (_) {
    return value;
  }
}

function formatShortDate(value, language) {
  if (!value) return '-';

  try {
    return new Intl.DateTimeFormat(
      language === 'tr' ? 'tr-TR' : 'en-US',
      { month: 'short', day: 'numeric' },
    ).format(new Date(value));
  } catch (_) {
    return value;
  }
}

function formatDuration(seconds, language = 'en') {
  const total = parseInt(seconds, 10);
  if (!total || Number.isNaN(total)) return '-';

  const hours = Math.floor(total / 3600);
  const minutes = Math.max(Math.round((total % 3600) / 60), 1);
  const hourUnit = language === 'tr' ? 'sa' : 'h';
  const minuteUnit = language === 'tr' ? 'dk' : 'm';

  if (hours > 0) return `${hours}${hourUnit} ${minutes}${minuteUnit}`;
  return `${minutes}${minuteUnit}`;
}

function normalizeError(error, fallback) {
  if (error instanceof Error && error.message) return error.message;
  return fallback;
}

function normalizeObjectList(value) {
  if (!Array.isArray(value)) return [];
  return value.filter((item) => item && typeof item === 'object');
}

async function fetchWorkspaceJson(path, options = {}) {
  const headers = new Headers(options.headers || {});
  if (!headers.has('Accept')) headers.set('Accept', 'application/json');

  const response = await fetch(path, {
    ...options,
    headers,
    credentials: 'same-origin',
  });

  let data = {};
  try {
    data = await response.json();
  } catch (_) {
    data = {};
  }

  if (!response.ok || data?.ok === false) {
    throw new Error(data?.error || data?.detail || `Request failed (${response.status})`);
  }

  return data;
}

function DetailTab({
  active, label, icon: Icon, onClick,
}) {
  return (
    <button
      type="button"
      role="tab"
      aria-selected={active}
      className={`ak-room-tab ${active ? 'is-active' : ''}`}
      onClick={onClick}
    >
      <Icon className="ak-room-tab-icon" aria-hidden="true" />
      <span>{label}</span>
    </button>
  );
}

function MetricTile({
  label, value, helper, accent = 'default',
}) {
  return (
    <div className={`ak-room-metric ak-room-metric-${accent}`}>
      <span className="ak-room-metric-label">{label}</span>
      <strong>{value}</strong>
      {helper && <small>{helper}</small>}
    </div>
  );
}

function AttributeTable({ rows, copy }) {
  return (
    <div className="ak-room-table-wrap ak-room-detail-table-wrap">
      <table className="ak-room-table ak-room-table-compact ak-room-detail-table">
        <thead>
          <tr>
            <th>#</th>
            <th>{copy.attributeName}</th>
            <th>{copy.attributeValue}</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row, index) => (
            <tr key={row.label}>
              <td className="ak-room-detail-table-index">{index + 1}</td>
              <td>{row.label}</td>
              <td className="ak-room-detail-table-value">{row.value}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function PanelHeader({ title, body, action }) {
  return (
    <header className="ak-room-panel-head">
      <div>
        <h2>{title}</h2>
        {body && <p>{body}</p>}
      </div>
      {action}
    </header>
  );
}

function InlineEmpty({ body }) {
  return (
    <div className="ak-room-empty">
      <p>{body}</p>
    </div>
  );
}

function SubTab({ active, label, onClick }) {
  return (
    <button
      type="button"
      className={`ak-room-subtab ${active ? 'is-active' : ''}`}
      onClick={onClick}
    >
      {label}
    </button>
  );
}

function TableFooter({
  page,
  rowsPerPage,
  totalItems,
  onPageChange,
  onRowsChange,
  copy,
}) {
  const totalPages = Math.max(Math.ceil((totalItems || 0) / rowsPerPage), 1);

  return (
    <div className="ak-room-table-footer">
      <label className="ak-room-table-rows">
        <span>{copy.rows}</span>
        <select
          value={rowsPerPage}
          onChange={(event) => {
            onRowsChange(parseInt(event.target.value, 10));
            onPageChange(1);
          }}
        >
          {[5, 10, 20].map((value) => (
            <option key={value} value={value}>{value}</option>
          ))}
        </select>
      </label>
      <div className="ak-room-table-page-controls">
        <button type="button" onClick={() => onPageChange(Math.max(page - 1, 1))} disabled={page <= 1}>
          {copy.prev}
        </button>
        <span>{copy.page} {page}/{totalPages}</span>
        <button type="button" onClick={() => onPageChange(Math.min(page + 1, totalPages))} disabled={page >= totalPages}>
          {copy.next}
        </button>
      </div>
    </div>
  );
}

function SelectFilter({
  label, value, options, onChange,
}) {
  return (
    <label className="ak-room-inline-filter">
      <span>{label}</span>
      <select value={value} onChange={(event) => onChange(event.target.value)}>
        {options.map((option) => (
          <option key={option.value} value={option.value}>{option.label}</option>
        ))}
      </select>
    </label>
  );
}

function getFutureStatus(meeting, copy) {
  const status = `${meeting?.status || ''}`.toLowerCase();
  const metadata = meeting?.metadata && typeof meeting.metadata === 'object' ? meeting.metadata : {};
  const metadataStatus = `${metadata?.status || metadata?.meeting_status || ''}`.toLowerCase();
  const hasLiveEvidence = (
    meeting?.is_active === true
    || metadata?.is_active === true
    || ['live', 'ongoing', 'started'].includes(status)
    || ['live', 'ongoing', 'started'].includes(metadataStatus)
  );

  if (hasLiveEvidence) {
    return {
      key: 'ongoing',
      label: copy.ongoing,
      className: 'is-ongoing',
    };
  }

  return {
    key: 'scheduled',
    label: copy.scheduled,
    className: 'is-scheduled',
  };
}

function safeNumber(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function averageOf(values) {
  if (!values.length) return 0;
  return Math.round(values.reduce((sum, value) => sum + value, 0) / values.length);
}

function buildActivityBuckets(events, bucketCount = 12) {
  const list = normalizeObjectList(events);
  if (!list.length) return [];

  const chunkSize = Math.max(Math.ceil(list.length / bucketCount), 1);
  const buckets = [];

  for (let index = 0; index < list.length; index += chunkSize) {
    buckets.push(list.slice(index, index + chunkSize).length);
  }

  return buckets.slice(0, bucketCount);
}

function normalizeDate(value) {
  if (!value) return null;
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function scoreBadgeClass(score) {
  if (safeNumber(score) >= 80) return 'is-ok';
  if (safeNumber(score) >= 60) return 'is-warn';
  return 'is-bad';
}

function escapeHtml(value) {
  return `${value ?? ''}`
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function downloadParticipantsExcel({
  rows,
  meetingName,
  filePrefix,
  language,
}) {
  if (!rows.length) return;

  const headers = [
    '#',
    'User',
    'User ID',
    'Role',
    'Status',
    'Join',
    'Leave',
    'Online Time',
    'ATT OK',
    'ATT LATE',
    'ATT MISSED',
    'QUIZ OK',
    'QUIZ NOK',
    'Messages',
    'Polls',
    'Hands Up/Down',
    'Focus/Blur',
    'Attendance Score',
    'Attention Score',
    'Engagement Score',
    'Activity Score',
    'Final Score',
  ];

  const bodyRows = rows.map((row, index) => ([
    index + 1,
    row.user,
    row.userId,
    row.role,
    row.statusLabel,
    formatDateTime(row.firstJoinAt, language),
    formatDateTime(row.lastLeaveAt, language),
    formatDuration(row.onlineSeconds, language),
    row.attendanceOk,
    row.attendanceLate,
    row.attendanceMissed,
    row.quizOk,
    row.quizNok,
    row.chatCount,
    row.pollAnswers,
    `${row.raiseHands}/${row.lowerHands}`,
    `${row.focusCount}/${row.blurCount}`,
    `${row.attendanceScore}%`,
    `${row.score > 0 ? row.score : row.scoreBasis}%`,
    `${row.engagementScore}%`,
    `${row.activityScore}%`,
    row.score > 0 ? row.score : row.scoreBasis,
  ]));

  const tableHead = headers.map((header) => `<th>${escapeHtml(header)}</th>`).join('');
  const tableBody = bodyRows
    .map((columns) => `<tr>${columns.map((column) => `<td>${escapeHtml(column)}</td>`).join('')}</tr>`)
    .join('');

  const html = `<!DOCTYPE html><html><head><meta charset="UTF-8" /></head><body><table border="1"><thead><tr>${tableHead}</tr></thead><tbody>${tableBody}</tbody></table></body></html>`;

  const blob = new Blob([`\uFEFF${html}`], { type: 'application/vnd.ms-excel;charset=utf-8;' });
  const link = document.createElement('a');
  const meetingSlug = `${meetingName || 'session-report'}`
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60);
  const fileName = `${filePrefix || 'session-report'}-${meetingSlug || 'report'}.xls`;
  const objectUrl = URL.createObjectURL(blob);

  link.href = objectUrl;
  link.download = fileName;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(objectUrl);
}

export default function FeatureTabs({ room }) {
  const { friendlyId } = useParams();
  const [searchParams, setSearchParams] = useSearchParams();
  const { isLoading: siteSettingsLoading, data: settings } = useSiteSetting(['PreuploadPresentation', 'ShareRooms']);
  const { isLoading: roomConfigLoading, data: recordValue } = useRoomConfigValue('record');
  const currentUser = useAuth();

  const language = currentUser?.language === 'tr' ? 'tr' : 'en';
  const copy = ROOM_COPY[language];
  const showRecordings = recordValue !== 'false';
  const isConfigLoading = siteSettingsLoading || roomConfigLoading;
  const extRoomId = room?.meeting_id || friendlyId;

  const tabConfig = useMemo(() => ([
    { key: 'overview', label: copy.tabs.overview, icon: Squares2X2Icon },
    { key: 'sessions', label: copy.tabs.sessions, icon: CalendarDaysIcon },
    { key: 'history', label: copy.tabs.history, icon: ChartBarIcon },
    { key: 'future', label: copy.tabs.future, icon: ClockIcon },
    { key: 'files', label: copy.tabs.files, icon: FolderIcon },
    { key: 'access', label: copy.tabs.access, icon: UserGroupIcon },
    { key: 'settings', label: copy.tabs.settings, icon: Cog6ToothIcon },
  ]), [copy]);
  const activeTab = tabConfig.some((tab) => tab.key === searchParams.get('tab')) ? searchParams.get('tab') : 'overview';

  const [futureMeetings, setFutureMeetings] = useState([]);
  const [pastMeetings, setPastMeetings] = useState([]);
  const [sessionsLoading, setSessionsLoading] = useState(true);
  const [sessionsStatus, setSessionsStatus] = useState({ message: '', error: false });
  const [selectedMeeting, setSelectedMeeting] = useState('');
  const [pastUsers, setPastUsers] = useState([]);
  const [meetingSummary, setMeetingSummary] = useState(null);
  const [reportTimeline, setReportTimeline] = useState([]);
  const [reportAttention, setReportAttention] = useState([]);
  const [reportCheckUsers, setReportCheckUsers] = useState([]);
  const [meetingDetailLoading, setMeetingDetailLoading] = useState(false);
  const [meetingDetailStatus, setMeetingDetailStatus] = useState({ message: '', error: false });
  const [historyView, setHistoryView] = useState('meetings');
  const [showReportModal, setShowReportModal] = useState(false);
  const [showPlannerModal, setShowPlannerModal] = useState(false);

  const [allSessionsFilter, setAllSessionsFilter] = useState('all');
  const [allSessionsPage, setAllSessionsPage] = useState(1);
  const [allSessionsRowsPerPage, setAllSessionsRowsPerPage] = useState(5);
  const [pastPage, setPastPage] = useState(1);
  const [pastRowsPerPage, setPastRowsPerPage] = useState(5);
  const [futurePage, setFuturePage] = useState(1);
  const [futureRowsPerPage, setFutureRowsPerPage] = useState(5);
  const [recordingsPage, setRecordingsPage] = useState(1);
  const [recordingsRowsPerPage, setRecordingsRowsPerPage] = useState(5);
  const [reportParticipantsPage, setReportParticipantsPage] = useState(1);
  const [reportParticipantsRowsPerPage, setReportParticipantsRowsPerPage] = useState(10);
  const [selectedParticipantKey, setSelectedParticipantKey] = useState('');
  const [showParticipantModal, setShowParticipantModal] = useState(false);
  const [participantDetailTab, setParticipantDetailTab] = useState('analytics');

  const [scheduleStatus, setScheduleStatus] = useState({ message: '', error: false });
  const [form, setForm] = useState({
    title: '',
    description: '',
    startAt: '',
    endAt: '',
    timezone: 'Europe/Istanbul',
  });

  const roomRecordings = useRoomRecordings(friendlyId, '', recordingsPage, recordingsRowsPerPage);

  const setActiveTab = (nextTab) => {
    const next = new URLSearchParams(searchParams);
    next.set('tab', nextTab);
    setSearchParams(next, { replace: true });
  };

  const loadSessions = useCallback(async () => {
    setSessionsLoading(true);
    setSessionsStatus({ message: '', error: false });

    try {
      const [futureData, pastData] = await Promise.all([
        fetchWorkspaceJson(`/ext/future-meetings?room=${encodeURIComponent(extRoomId)}&limit=100&includePast=1`),
        fetchWorkspaceJson(`/ext/past-meetings?room=${encodeURIComponent(extRoomId)}&limit=100&includeRecordings=1`),
      ]);
      const nextFuture = normalizeObjectList(futureData.future_meetings);
      const nextPast = normalizeObjectList(pastData.meetings);
      setFutureMeetings(nextFuture);
      setPastMeetings(nextPast);
      setSelectedMeeting((prev) => {
        if (prev && nextPast.find((meeting) => meeting.meeting_int_id === prev)) return prev;
        return nextPast[0]?.meeting_int_id || '';
      });
    } catch (error) {
      setFutureMeetings([]);
      setPastMeetings([]);
      setSelectedMeeting('');
      setSessionsStatus({ message: normalizeError(error, copy.history.loadError), error: true });
    } finally {
      setSessionsLoading(false);
    }
  }, [copy.history.loadError, extRoomId]);

  useEffect(() => {
    loadSessions();
  }, [loadSessions]);

  useEffect(() => {
    let active = true;

    const loadMeetingDetail = async () => {
      if (!selectedMeeting) {
        setPastUsers([]);
        setMeetingSummary(null);
        setReportTimeline([]);
        setReportAttention([]);
        setReportCheckUsers([]);
        setMeetingDetailStatus({ message: '', error: false });
        return;
      }

      setMeetingDetailLoading(true);
      try {
        const [usersData, summaryData, timelineData, attentionData, checksData] = await Promise.all([
          fetchWorkspaceJson(`/ext/past-meeting-users?meeting_int_id=${encodeURIComponent(selectedMeeting)}`),
          fetchWorkspaceJson(`/ext/engagement-summary?meeting_int_id=${encodeURIComponent(selectedMeeting)}`),
          fetchWorkspaceJson(`/ext/engagement-timeline?meeting_int_id=${encodeURIComponent(selectedMeeting)}&limit=240`),
          fetchWorkspaceJson(`/ext/attention-score?meeting_int_id=${encodeURIComponent(selectedMeeting)}&limit=500`),
          fetchWorkspaceJson(`/ext/meeting-checks/user-summary?meeting_int_id=${encodeURIComponent(selectedMeeting)}`),
        ]);

        if (!active) return;
        setPastUsers(normalizeObjectList(usersData.users));
        setMeetingSummary(summaryData || null);
        setReportTimeline(normalizeObjectList(timelineData.events));
        setReportAttention(normalizeObjectList(attentionData.users));
        setReportCheckUsers(normalizeObjectList(checksData.users));
        setMeetingDetailStatus({ message: '', error: false });
      } catch (error) {
        if (!active) return;
        setPastUsers([]);
        setMeetingSummary(null);
        setReportTimeline([]);
        setReportAttention([]);
        setReportCheckUsers([]);
        setMeetingDetailStatus({ message: normalizeError(error, copy.history.loadError), error: true });
      } finally {
        if (active) setMeetingDetailLoading(false);
      }
    };

    loadMeetingDetail();

    return () => {
      active = false;
    };
  }, [copy.history.loadError, selectedMeeting]);

  useEffect(() => {
    setAllSessionsPage(1);
  }, [allSessionsFilter]);

  useEffect(() => {
    setReportParticipantsPage(1);
  }, [selectedMeeting]);

  useEffect(() => {
    setSelectedParticipantKey('');
    setShowParticipantModal(false);
  }, [selectedMeeting]);

  const setField = (key, value) => {
    setForm((prev) => ({ ...prev, [key]: value }));
  };

  const createFutureMeeting = async (event) => {
    event.preventDefault();
    if (!form.title.trim() || !form.startAt || !form.endAt) {
      setScheduleStatus({ message: copy.future.required, error: true });
      return;
    }

    try {
      await fetchWorkspaceJson('/ext/future-meetings/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          room: extRoomId,
          title: form.title.trim(),
          description: form.description.trim(),
          start_at: new Date(form.startAt).toISOString(),
          end_at: new Date(form.endAt).toISOString(),
          timezone: form.timezone || 'Europe/Istanbul',
          created_by: currentUser?.name || currentUser?.email || 'greenlight',
          metadata: { source: 'greenlight-room-detail' },
        }),
      });

      setScheduleStatus({ message: copy.future.created, error: false });
      setForm((prev) => ({
        ...prev,
        title: '',
        description: '',
        startAt: '',
        endAt: '',
      }));
      setShowPlannerModal(false);
      await loadSessions();
    } catch (error) {
      setScheduleStatus({ message: normalizeError(error, copy.future.error), error: true });
    }
  };

  const cancelFutureMeeting = async (id) => {
    try {
      await fetchWorkspaceJson('/ext/future-meetings/cancel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: String(id) }),
      });
      setScheduleStatus({ message: copy.future.cancelled, error: false });
      await loadSessions();
    } catch (error) {
      setScheduleStatus({ message: normalizeError(error, copy.future.error), error: true });
    }
  };

  const startFutureMeetingNow = async (meeting) => {
    if (!meeting?.id) return;

    try {
      let joinUrl = meeting.join_url || '';

      if (friendlyId) {
        const response = await axios.post(`/meetings/${friendlyId}/start.json`);
        joinUrl = response?.data?.data || joinUrl;
      }

      await fetchWorkspaceJson('/ext/future-meetings/cancel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: String(meeting.id) }),
      });

      await loadSessions();
      setScheduleStatus({ message: copy.future.startedNow, error: false });

      if (joinUrl) {
        window.open(joinUrl, '_blank', 'noopener,noreferrer');
      }
    } catch (error) {
      setScheduleStatus({ message: normalizeError(error, copy.future.error), error: true });
    }
  };

  const selectedMeetingData = useMemo(
    () => pastMeetings.find((meeting) => meeting.meeting_int_id === selectedMeeting) || null,
    [pastMeetings, selectedMeeting],
  );

  const allSessions = useMemo(() => {
    const mappedFuture = futureMeetings.map((meeting) => {
      const status = getFutureStatus(meeting, copy.sessions);
      return {
        key: `future-${meeting.id}`,
        scheduleId: String(meeting.id || ''),
        when: meeting.start_at,
        endAt: meeting.end_at,
        title: meeting.title || meeting.meeting_name || friendlyId,
        type: copy.sessions.futureType,
        attendees: '-',
        duration: '-',
        statusKey: status.key,
        statusLabel: status.label,
        statusClass: status.className,
        joinUrl: meeting.join_url || '',
        sourceMeeting: meeting,
        meetingId: '',
        createdAt: meeting.start_at,
      };
    });

    const mappedPast = pastMeetings.map((meeting) => ({
      key: `past-${meeting.meeting_int_id}`,
      scheduleId: '',
      when: meeting.created_at || meeting.started_at || meeting.ended_at,
      endAt: meeting.ended_at,
      title: meeting.meeting_name || meeting.meeting_int_id || '-',
      type: copy.sessions.pastType,
      attendees: meeting.participants_count || 0,
      duration: formatDuration(meeting.duration_seconds, language),
      statusKey: 'completed',
      statusLabel: copy.sessions.completed,
      statusClass: 'is-complete',
      joinUrl: '',
      meetingId: meeting.meeting_int_id,
      sourceMeeting: null,
      createdAt: meeting.created_at || meeting.ended_at || meeting.started_at,
    }));

    return [...mappedFuture, ...mappedPast].sort((left, right) => {
      const leftTime = new Date(left.createdAt || 0).getTime();
      const rightTime = new Date(right.createdAt || 0).getTime();
      return rightTime - leftTime;
    });
  }, [copy.sessions, friendlyId, futureMeetings, language, pastMeetings]);

  const filteredSessions = useMemo(() => (
    allSessionsFilter === 'all'
      ? allSessions
      : allSessions.filter((session) => session.statusKey === allSessionsFilter)
  ), [allSessions, allSessionsFilter]);

  const pagedSessions = useMemo(() => {
    const start = (allSessionsPage - 1) * allSessionsRowsPerPage;
    return filteredSessions.slice(start, start + allSessionsRowsPerPage);
  }, [allSessionsPage, allSessionsRowsPerPage, filteredSessions]);

  const pagedPastMeetings = useMemo(() => {
    const start = (pastPage - 1) * pastRowsPerPage;
    return pastMeetings.slice(start, start + pastRowsPerPage);
  }, [pastMeetings, pastPage, pastRowsPerPage]);

  const pagedFutureMeetings = useMemo(() => {
    const start = (futurePage - 1) * futureRowsPerPage;
    return futureMeetings.slice(start, start + futureRowsPerPage);
  }, [futureMeetings, futurePage, futureRowsPerPage]);

  const recordingHref = selectedMeetingData?.recording?.playback?.url || '';
  const exportCsvHref = selectedMeeting ? `/ext/export/attendance.csv?meeting_int_id=${encodeURIComponent(selectedMeeting)}&includeChecks=1` : '';
  const exportJsonHref = selectedMeeting ? `/ext/export/attendance.json?meeting_int_id=${encodeURIComponent(selectedMeeting)}&includeChecks=1` : '';
  const summaryAttendance = meetingSummary?.attendance || {};
  const summaryEngagement = meetingSummary?.engagement || {};
  const roomIcsHref = `/ext/future-meetings/ics?room=${encodeURIComponent(extRoomId)}`;
  const reportAnalytics = useMemo(() => {
    const participantsCount = safeNumber(summaryAttendance.participants_count) || pastUsers.length;
    const checksOk = safeNumber(summaryAttendance.checks_ok);
    const checksLate = safeNumber(summaryAttendance.checks_late);
    const checksMissed = safeNumber(summaryAttendance.checks_missed);
    const totalChecks = checksOk + checksLate + checksMissed;

    const focusTotal = reportAttention.reduce((sum, user) => sum + safeNumber(user.focus_count), 0);
    const blurTotal = reportAttention.reduce((sum, user) => sum + safeNumber(user.blur_count), 0);
    const scoreValues = reportAttention
      .map((user) => safeNumber(user.compliance_score))
      .filter((value) => value > 0);

    const attentionScore = safeNumber(summaryEngagement.attention_score) || averageOf(scoreValues);
    const attendanceScore = totalChecks > 0
      ? Math.round(((checksOk + (checksLate * 0.5)) / totalChecks) * 100)
      : 0;
    const checkPass = totalChecks > 0 ? Math.round((checksOk / totalChecks) * 100) : 0;
    const focusRate = (focusTotal + blurTotal) > 0
      ? Math.round((focusTotal / (focusTotal + blurTotal)) * 100)
      : 0;

    const pollCount = reportTimeline.filter((event) => {
      const type = `${event.event_type || ''}`.toLowerCase();
      return type.includes('poll') || !!event.poll_id;
    }).length;
    const quizCount = reportTimeline.filter((event) => {
      const type = `${event.event_type || ''}`.toLowerCase();
      return type.includes('quiz') || type.includes('check');
    }).length;
    const activityScore = safeNumber(summaryEngagement.activity_score)
      || Math.min(100, Math.round((reportTimeline.length / Math.max(participantsCount || 1, 1)) * 10));

    return {
      participantsCount,
      checksOk,
      checksLate,
      checksMissed,
      totalChecks,
      attentionScore,
      attendanceScore,
      checkPass,
      focusTotal,
      blurTotal,
      focusRate,
      pollCount,
      quizCount,
      activityScore,
      timelineCount: reportTimeline.length,
      buckets: buildActivityBuckets(reportTimeline, 12),
    };
  }, [pastUsers.length, reportAttention, reportTimeline, summaryAttendance, summaryEngagement]);
  const participantReportRows = useMemo(() => {
    const timelineByUser = new Map();
    const meetingEnd = normalizeDate(selectedMeetingData?.ended_at);

    reportTimeline.forEach((event) => {
      const key = `${event.user_id || ''}-${event.name || ''}`;
      const bucket = timelineByUser.get(key) || {
        joins: [],
        leaves: [],
        chatCount: 0,
        pollAnswers: 0,
        raiseHands: 0,
        lowerHands: 0,
        eventCount: 0,
      };
      const eventAt = normalizeDate(event.event_at);
      const eventType = `${event.event_type || ''}`.toLowerCase();

      if (eventType === 'join' && eventAt) bucket.joins.push(eventAt);
      if (eventType === 'leave' && eventAt) bucket.leaves.push(eventAt);
      if (eventType === 'chat') bucket.chatCount += 1;
      if (eventType === 'poll_answered') bucket.pollAnswers += 1;
      if (eventType === 'raise_hand') bucket.raiseHands += 1;
      if (eventType === 'lower_hand') bucket.lowerHands += 1;
      if (eventType) bucket.eventCount += 1;

      timelineByUser.set(key, bucket);
    });

    const rowMap = new Map();

    reportCheckUsers.forEach((user) => {
      const key = `${user.user_id || ''}-${user.name || ''}`;
      rowMap.set(key, {
        key,
        user: user.name || user.user_id || '-',
        userId: user.user_id || '-',
        role: user.role || '-',
        attendanceTotal: safeNumber(user.attendance_total),
        attendanceOk: safeNumber(user.attendance_ok),
        attendanceLate: safeNumber(user.attendance_late),
        attendanceMissed: safeNumber(user.attendance_missed),
        quizTotal: safeNumber(user.quiz_total),
        quizOk: safeNumber(user.quiz_ok),
        quizFailed: safeNumber(user.quiz_failed),
        quizLate: safeNumber(user.quiz_late),
        quizMissed: safeNumber(user.quiz_missed),
        genericChecksOk: 0,
        genericChecksTotal: 0,
        genericChecksLate: 0,
        genericChecksMissed: 0,
        focusCount: 0,
        blurCount: 0,
        idleCount: 0,
        activeCount: 0,
        score: 0,
        firstCheckAt: user.first_check_at || '',
        lastCheckAt: user.last_check_at || '',
      });
    });

    pastUsers.forEach((user) => {
      const key = `${user.user_id || ''}-${user.name || ''}`;
      const existing = rowMap.get(key) || {
        key,
        user: user.name || user.user_id || '-',
        userId: user.user_id || '-',
        role: user.role || '-',
        attendanceTotal: 0,
        attendanceOk: 0,
        attendanceLate: 0,
        attendanceMissed: 0,
        quizTotal: 0,
        quizOk: 0,
        quizFailed: 0,
        quizLate: 0,
        quizMissed: 0,
        genericChecksOk: 0,
        genericChecksTotal: 0,
        genericChecksLate: 0,
        genericChecksMissed: 0,
        focusCount: 0,
        blurCount: 0,
        idleCount: 0,
        activeCount: 0,
        score: 0,
        firstCheckAt: '',
        lastCheckAt: '',
      };

      existing.user = user.name || existing.user;
      existing.userId = user.user_id || existing.userId;
      existing.role = user.role || existing.role;
      existing.genericChecksOk = safeNumber(user.checks_ok) || existing.genericChecksOk;
      existing.genericChecksTotal = safeNumber(user.checks_total) || existing.genericChecksTotal;
      existing.genericChecksLate = safeNumber(user.checks_late) || existing.genericChecksLate;
      existing.genericChecksMissed = safeNumber(user.checks_missed) || existing.genericChecksMissed;
      existing.firstCheckAt = user.first_check_at || existing.firstCheckAt;
      existing.lastCheckAt = user.last_check_at || existing.lastCheckAt;
      rowMap.set(key, existing);
    });

    reportAttention.forEach((user) => {
      const key = `${user.user_id || ''}-${user.name || ''}`;
      const existing = rowMap.get(key) || {
        key,
        user: user.name || user.user_id || '-',
        userId: user.user_id || '-',
        role: user.role || '-',
        attendanceTotal: 0,
        attendanceOk: 0,
        attendanceLate: 0,
        attendanceMissed: 0,
        quizTotal: 0,
        quizOk: 0,
        quizFailed: 0,
        quizLate: 0,
        quizMissed: 0,
        genericChecksOk: 0,
        genericChecksTotal: 0,
        genericChecksLate: 0,
        genericChecksMissed: 0,
        focusCount: 0,
        blurCount: 0,
        idleCount: 0,
        activeCount: 0,
        score: 0,
      };

      existing.user = user.name || existing.user;
      existing.userId = user.user_id || existing.userId;
      existing.role = user.role || existing.role;
      existing.genericChecksOk = safeNumber(user.checks_ok) || existing.genericChecksOk;
      existing.genericChecksTotal = safeNumber(user.checks_total) || existing.genericChecksTotal;
      existing.genericChecksLate = safeNumber(user.checks_late) || existing.genericChecksLate;
      existing.genericChecksMissed = safeNumber(user.checks_missed) || existing.genericChecksMissed;
      existing.focusCount = safeNumber(user.focus_count);
      existing.blurCount = safeNumber(user.blur_count);
      existing.idleCount = safeNumber(user.idle_count);
      existing.activeCount = safeNumber(user.active_count);
      existing.score = safeNumber(user.compliance_score);
      rowMap.set(key, existing);
    });

    const rows = [...rowMap.values()].map((row) => {
      const timeline = timelineByUser.get(row.key) || {
        joins: [],
        leaves: [],
        chatCount: 0,
        pollAnswers: 0,
        raiseHands: 0,
        lowerHands: 0,
        eventCount: 0,
      };
      const firstJoinAt = timeline.joins.length
        ? new Date(Math.min(...timeline.joins.map((item) => item.getTime())))
        : null;
      const lastLeaveAt = timeline.leaves.length
        ? new Date(Math.max(...timeline.leaves.map((item) => item.getTime())))
        : null;

      let onlineSeconds = 0;
      if (firstJoinAt) {
        const fallbackEnd = lastLeaveAt || meetingEnd || null;
        if (fallbackEnd) {
          onlineSeconds = Math.max(Math.round((fallbackEnd.getTime() - firstJoinAt.getTime()) / 1000), 0);
        }
      }

      const attendanceTotal = row.attendanceTotal || row.genericChecksTotal || (row.genericChecksOk + row.genericChecksLate + row.genericChecksMissed);
      const attendanceOk = row.attendanceTotal ? row.attendanceOk : row.genericChecksOk;
      const attendanceLate = row.attendanceTotal ? row.attendanceLate : row.genericChecksLate;
      const attendanceMissed = row.attendanceTotal ? row.attendanceMissed : row.genericChecksMissed;
      const quizTotal = row.quizTotal;
      const quizOk = row.quizOk;
      const quizFailed = row.quizFailed;
      const quizLate = row.quizLate;
      const quizMissed = row.quizMissed;
      const quizNok = quizFailed + quizLate + quizMissed;
      const attendanceOnlyScore = attendanceTotal > 0
        ? Math.round(((attendanceOk + (attendanceLate * 0.5)) / attendanceTotal) * 100)
        : 0;
      const quizOnlyScore = quizTotal > 0
        ? Math.round(((quizOk + (quizLate * 0.5)) / quizTotal) * 100)
        : 0;
      const attendanceScore = quizTotal > 0
        ? Math.round((attendanceOnlyScore * 0.6) + (quizOnlyScore * 0.4))
        : attendanceOnlyScore;
      const focusRate = (row.focusCount + row.blurCount) > 0
        ? Math.round((row.focusCount / (row.focusCount + row.blurCount)) * 100)
        : 0;
      const activityBase = (timeline.chatCount * 5) + (timeline.pollAnswers * 8) + (timeline.raiseHands * 6) + (timeline.eventCount * 2);
      const activityScore = Math.min(100, Math.round(activityBase));
      const engagementScore = Math.round(
        (attendanceScore * 0.35)
        + (focusRate * 0.3)
        + (Math.min(activityScore, 100) * 0.35),
      );
      const combinedChecksTotal = attendanceTotal + quizTotal;
      const combinedChecksPassed = attendanceOk + quizOk;
      const checkPassRate = combinedChecksTotal > 0
        ? Math.round((combinedChecksPassed / combinedChecksTotal) * 100)
        : 0;
      const scoreBasis = row.score > 0
        ? row.score
        : Math.round((attendanceScore * 0.45) + (focusRate * 0.25) + (activityScore * 0.3));

      const meetingDurationSeconds = safeNumber(selectedMeetingData?.duration_seconds);
      let statusLabel = scoreBasis >= 85 ? copy.history.statusStrong : scoreBasis >= 60 ? copy.history.statusWatch : copy.history.statusRisk;
      let statusClass = scoreBasis >= 85 ? 'is-ok' : scoreBasis >= 60 ? 'is-warn' : 'is-bad';

      if (meetingDurationSeconds > 0 && onlineSeconds > 0 && onlineSeconds < Math.round(meetingDurationSeconds * 0.6)) {
        statusLabel = copy.history.statusLeftEarly;
        statusClass = 'is-warn';
      } else if (!firstJoinAt && combinedChecksTotal === 0) {
        statusLabel = copy.history.statusNoEvidence;
        statusClass = 'is-bad';
      }

      return {
        ...row,
        attendanceTotal,
        attendanceOk,
        attendanceLate,
        attendanceMissed,
        quizTotal,
        quizOk,
        quizFailed,
        quizLate,
        quizMissed,
        quizNok,
        firstJoinAt,
        lastLeaveAt,
        onlineSeconds,
        attendanceScore,
        attendanceOnlyScore,
        quizOnlyScore,
        focusRate,
        chatCount: timeline.chatCount,
        pollAnswers: timeline.pollAnswers,
        raiseHands: timeline.raiseHands,
        lowerHands: timeline.lowerHands,
        activityEvents: timeline.eventCount,
        activityScore,
        engagementScore,
        checkPassRate,
        statusLabel,
        statusClass,
        meetingDurationSeconds,
        scoreBasis,
      };
    });

    return rows.sort((left, right) => right.engagementScore - left.engagementScore);
  }, [copy.history.statusLeftEarly, copy.history.statusNoEvidence, copy.history.statusRisk, copy.history.statusStrong, copy.history.statusWatch, pastUsers, reportAttention, reportCheckUsers, reportTimeline, selectedMeetingData]);
  const pagedParticipantReportRows = useMemo(() => {
    const start = (reportParticipantsPage - 1) * reportParticipantsRowsPerPage;
    return participantReportRows.slice(start, start + reportParticipantsRowsPerPage);
  }, [participantReportRows, reportParticipantsPage, reportParticipantsRowsPerPage]);
  const nativeAnalyticsHref = '/learning-analytics-dashboard/';
  const selectedParticipantRow = useMemo(
    () => participantReportRows.find((row) => row.key === selectedParticipantKey) || null,
    [participantReportRows, selectedParticipantKey],
  );

  useEffect(() => {
    if (showParticipantModal) {
      setParticipantDetailTab('analytics');
    }
  }, [selectedParticipantKey, showParticipantModal]);

  const renderOverview = () => {
    const maxDuration = Math.max(...pastMeetings.map((meeting) => meeting.duration_seconds || 0), 1);

    return (
      <div className="ak-room-panel">
        <PanelHeader title={copy.overview.title} body={copy.overview.body} />

        <div className="ak-room-metric-grid">
          <MetricTile
            label={copy.overview.live}
            value={room?.online ? copy.overview.stateLive : copy.overview.stateIdle}
            helper={friendlyId}
            accent={room?.online ? 'good' : 'default'}
          />
          <MetricTile label={copy.overview.attendees} value={room?.participants || 0} helper={room?.name} accent="blue" />
          <MetricTile label={copy.overview.upcoming} value={futureMeetings.length} helper={copy.future.title} accent="accent" />
          <MetricTile label={copy.overview.completed} value={pastMeetings.length} helper={copy.history.title} accent="dark" />
        </div>

        <div className="ak-room-split-grid">
          <section className="ak-room-surface">
            <div className="ak-room-surface-head">
              <h3>{copy.overview.activity}</h3>
            </div>
            {!pastMeetings.length && <InlineEmpty body={copy.overview.activityEmpty} />}
            {!!pastMeetings.length && (
              <div className="ak-room-activity-list">
                {pastMeetings.slice(0, 6).map((meeting) => (
                  <div key={meeting.meeting_int_id} className="ak-room-activity-row">
                    <span>{formatShortDate(meeting.created_at, language)}</span>
                    <div className="ak-room-activity-track">
                      <span
                        className="ak-room-activity-fill"
                        style={{ width: `${Math.max(Math.round(((meeting.duration_seconds || 0) / maxDuration) * 100), 10)}%` }}
                      />
                    </div>
                    <small>{formatDuration(meeting.duration_seconds, language)}</small>
                  </div>
                ))}
              </div>
            )}
          </section>

          <section className="ak-room-surface">
            <div className="ak-room-surface-head">
              <h3>{copy.overview.shortcuts}</h3>
              <p>{copy.overview.shortcutsBody}</p>
            </div>
            <div className="ak-room-shortcuts">
              <button type="button" className="ak-room-link-btn" onClick={() => setActiveTab('sessions')}>{copy.overview.goSessions}</button>
              <button type="button" className="ak-room-link-btn" onClick={() => setActiveTab('future')}>{copy.overview.goFuture}</button>
              <button type="button" className="ak-room-link-btn" onClick={() => setActiveTab('history')}>{copy.overview.goHistory}</button>
              <button type="button" className="ak-room-link-btn" onClick={() => setActiveTab('settings')}>{copy.overview.goSettings}</button>
            </div>
          </section>
        </div>
      </div>
    );
  };

  const renderAllSessions = () => (
    <div className="ak-room-panel">
      <PanelHeader
        title={copy.sessions.title}
        body={copy.sessions.body}
        action={(
          <SelectFilter
            label={copy.sessions.filters}
            value={allSessionsFilter}
            onChange={setAllSessionsFilter}
            options={[
              { value: 'all', label: copy.common.all },
              { value: 'scheduled', label: copy.sessions.scheduled },
              { value: 'ongoing', label: copy.sessions.ongoing },
              { value: 'completed', label: copy.sessions.completed },
            ]}
          />
        )}
      />
      {sessionsStatus.message && (
        <p className={`ak-room-status ${sessionsStatus.error ? 'is-error' : ''}`}>{sessionsStatus.message}</p>
      )}
      <section className="ak-room-surface">
        <div className="ak-room-table-wrap">
          <table className="ak-room-table">
            <thead>
              <tr>
                <th>{copy.sessions.date}</th>
                <th>{copy.sessions.end}</th>
                <th>{copy.sessions.titleCol}</th>
                <th>{copy.sessions.type}</th>
                <th>{copy.sessions.attendees}</th>
                <th>{copy.sessions.duration}</th>
                <th>{copy.sessions.status}</th>
                <th>{copy.sessions.action}</th>
              </tr>
            </thead>
            <tbody>
              {sessionsLoading && (
                <tr><td colSpan="8">{copy.common.loading}</td></tr>
              )}
              {!sessionsLoading && !pagedSessions.length && (
                <tr><td colSpan="8">{copy.sessions.noData}</td></tr>
              )}
              {!sessionsLoading && pagedSessions.map((session) => (
                <tr key={session.key}>
                  <td>{formatDateTime(session.when, language)}</td>
                  <td>{formatDateTime(session.endAt, language)}</td>
                  <td>{session.title}</td>
                  <td>{session.type}</td>
                  <td>{session.attendees}</td>
                  <td>{session.duration}</td>
                  <td>
                    <span className={`ak-room-table-badge ${session.statusClass}`}>
                      {session.statusLabel}
                    </span>
                  </td>
                  <td>
                    <div className="ak-room-inline-actions ak-room-inline-actions-wrap">
                      {session.statusKey === 'scheduled' && (
                        <>
                          <button
                            type="button"
                            className="ak-room-row-btn"
                            onClick={() => startFutureMeetingNow(session.sourceMeeting)}
                          >
                            {copy.sessions.startNow}
                          </button>
                          <button
                            type="button"
                            className="ak-room-row-btn"
                            onClick={() => cancelFutureMeeting(session.scheduleId)}
                          >
                            {copy.future.cancel}
                          </button>
                        </>
                      )}
                      {session.statusKey === 'ongoing' && session.joinUrl && (
                        <a href={session.joinUrl} target="_blank" rel="noreferrer" className="ak-room-row-btn">
                          {copy.sessions.open}
                        </a>
                      )}
                      {session.statusKey === 'completed' && !!session.meetingId && (
                        <button
                          type="button"
                          className="ak-room-row-btn"
                          onClick={() => {
                            setSelectedMeeting(session.meetingId);
                            setShowReportModal(true);
                          }}
                        >
                          {copy.sessions.viewReport}
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {!sessionsLoading && !!filteredSessions.length && (
          <TableFooter
            page={allSessionsPage}
            rowsPerPage={allSessionsRowsPerPage}
            totalItems={filteredSessions.length}
            onPageChange={setAllSessionsPage}
            onRowsChange={setAllSessionsRowsPerPage}
            copy={copy.common}
          />
        )}
      </section>
    </div>
  );

  const renderMeetingReportModal = () => (
    <BootstrapModal show={showReportModal} onHide={() => setShowReportModal(false)} centered size="xl" dialogClassName="ak-room-report-modal">
      <BootstrapModal.Header closeButton>
        <BootstrapModal.Title>{copy.history.reportTitle}</BootstrapModal.Title>
      </BootstrapModal.Header>
      <BootstrapModal.Body>
        {(meetingDetailStatus.message) && (
          <p className={`ak-room-status ${meetingDetailStatus.error ? 'is-error' : ''}`}>{meetingDetailStatus.message}</p>
        )}
        <section className="ak-room-report-intro">
          <div>
            <h3>{selectedMeetingData?.meeting_name || selectedMeeting || copy.common.noData}</h3>
            <p>{copy.history.reportSubtitle}</p>
          </div>
          {selectedMeetingData?.created_at && (
            <span className="ak-room-report-meta">{formatDateTime(selectedMeetingData.created_at, language)}</span>
          )}
        </section>

        <div className="ak-room-metric-grid ak-room-report-kpis">
          <MetricTile label={copy.history.participants} value={reportAnalytics.participantsCount} accent="blue" />
          <MetricTile label={copy.history.attendanceScore} value={`${reportAnalytics.attendanceScore}%`} accent="accent" />
          <MetricTile label={copy.history.attentionScore} value={`${reportAnalytics.attentionScore}%`} accent="dark" />
          <MetricTile label={copy.history.focusRate} value={`${reportAnalytics.focusRate}%`} accent="good" />
          <MetricTile label={copy.history.checkPass} value={`${reportAnalytics.checkPass}%`} accent="default" />
        </div>

        <div className="ak-room-inline-actions ak-room-report-actions">
          {recordingHref && <a href={recordingHref} target="_blank" rel="noreferrer" className="ak-room-link-btn">{copy.history.recording}</a>}
          <button
            type="button"
            className="ak-room-link-btn"
            onClick={() => downloadParticipantsExcel({
              rows: participantReportRows,
              meetingName: selectedMeetingData?.meeting_name || selectedMeeting,
              filePrefix: 'room-session-report',
              language,
            })}
            disabled={!participantReportRows.length}
          >
            {copy.history.exportExcel}
          </button>
          {exportCsvHref && <a href={exportCsvHref} target="_blank" rel="noreferrer" className="ak-room-link-btn">{copy.history.exportCsv}</a>}
          {exportJsonHref && <a href={exportJsonHref} target="_blank" rel="noreferrer" className="ak-room-link-btn">{copy.history.exportJson}</a>}
          <a href={nativeAnalyticsHref} target="_blank" rel="noreferrer" className="ak-room-link-btn">{copy.history.openNative}</a>
        </div>

        <div className="ak-room-report-grid ak-room-report-grid-bottom">
          <section className="ak-room-surface ak-room-report-participants-surface">
            <div className="ak-room-surface-head">
              <h3>{copy.history.participants}</h3>
            </div>
            <div className="ak-room-table-wrap ak-room-modal-table">
              <table className="ak-room-table ak-room-table-compact">
                <thead>
                  <tr>
                    <th>{copy.history.user}</th>
                    <th>{copy.history.role}</th>
                    <th>{copy.history.status}</th>
                    <th>{copy.history.joinTime}</th>
                    <th>{copy.history.leaveTime}</th>
                    <th>{copy.history.onlineTime}</th>
                    <th>{copy.history.checksOkLabel}</th>
                    <th>{copy.history.checksMissedLabel}</th>
                    <th>{copy.history.quizOkLabel}</th>
                    <th>{copy.history.quizNokLabel}</th>
                    <th>{copy.history.chatMessages}</th>
                    <th>{copy.history.pollAnswers}</th>
                    <th>{copy.history.raiseHands}</th>
                    <th>{copy.history.focusBlur}</th>
                    <th>{copy.history.attendanceScore}</th>
                    <th>{copy.history.engagementScore}</th>
                    <th>{copy.history.activityMetric}</th>
                    <th>{copy.history.score}</th>
                    <th>{copy.history.detailAction}</th>
                  </tr>
                </thead>
                <tbody>
                  {meetingDetailLoading && <tr><td colSpan="19">{copy.common.loading}</td></tr>}
                  {!meetingDetailLoading && !selectedMeeting && <tr><td colSpan="19">{copy.common.noData}</td></tr>}
                  {!meetingDetailLoading && !!selectedMeeting && !participantReportRows.length && <tr><td colSpan="19">{copy.history.noUsers}</td></tr>}
                  {!meetingDetailLoading && pagedParticipantReportRows.map((user) => (
                    <tr key={user.key}>
                      <td>{user.user}</td>
                      <td>{user.role}</td>
                      <td><span className={`ak-room-badge ${user.statusClass}`}>{user.statusLabel}</span></td>
                      <td>{formatDateTime(user.firstJoinAt, language)}</td>
                      <td>{formatDateTime(user.lastLeaveAt, language)}</td>
                      <td>{formatDuration(user.onlineSeconds, language)}</td>
                      <td>{user.attendanceOk}</td>
                      <td>{user.attendanceMissed}</td>
                      <td>{user.quizOk}</td>
                      <td>{user.quizNok}</td>
                      <td>{user.chatCount}</td>
                      <td>{user.pollAnswers}</td>
                      <td>{`${user.raiseHands}/${user.lowerHands}`}</td>
                      <td>{`${user.focusCount}/${user.blurCount}`}</td>
                      <td>{`${user.attendanceScore}%`}</td>
                      <td>{`${user.engagementScore}%`}</td>
                      <td>{`${user.activityScore}%`}</td>
                      <td>{user.score > 0 ? user.score : user.scoreBasis}</td>
                      <td>
                        <button
                          type="button"
                          className="ak-room-row-btn"
                          onClick={() => {
                            setSelectedParticipantKey(user.key);
                            setShowParticipantModal(true);
                          }}
                        >
                          {copy.history.detailAction}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {!meetingDetailLoading && !!participantReportRows.length && (
              <TableFooter
                page={reportParticipantsPage}
                rowsPerPage={reportParticipantsRowsPerPage}
                totalItems={participantReportRows.length}
                onPageChange={setReportParticipantsPage}
                onRowsChange={setReportParticipantsRowsPerPage}
                copy={copy.common}
              />
            )}
          </section>
        </div>
      </BootstrapModal.Body>
    </BootstrapModal>
  );

  const renderParticipantDetailModal = () => {
    const participantAttentionScore = selectedParticipantRow?.score > 0
      ? selectedParticipantRow.score
      : selectedParticipantRow?.scoreBasis;

    const analyticsRows = selectedParticipantRow ? [
      { label: copy.history.userIdLabel, value: selectedParticipantRow.userId || '-' },
      { label: copy.history.role, value: selectedParticipantRow.role || '-' },
      { label: copy.history.status, value: selectedParticipantRow.statusLabel || '-' },
      { label: copy.history.joinTime, value: formatDateTime(selectedParticipantRow.firstJoinAt, language) },
      { label: copy.history.leaveTime, value: formatDateTime(selectedParticipantRow.lastLeaveAt, language) },
      { label: copy.history.onlineTime, value: formatDuration(selectedParticipantRow.onlineSeconds, language) },
      { label: copy.history.firstCheck, value: formatDateTime(selectedParticipantRow.firstCheckAt, language) },
      { label: copy.history.lastCheck, value: formatDateTime(selectedParticipantRow.lastCheckAt, language) },
      { label: copy.history.idleActive, value: `${selectedParticipantRow.idleCount}/${selectedParticipantRow.activeCount}` },
      { label: copy.history.attendanceScore, value: `${selectedParticipantRow.attendanceScore}%` },
      { label: copy.history.attentionScore, value: `${participantAttentionScore}%` },
      { label: copy.history.engagementScore, value: `${selectedParticipantRow.engagementScore}%` },
      { label: copy.history.activityMetric, value: `${selectedParticipantRow.activityScore}%` },
    ] : [];

    const checksRows = selectedParticipantRow ? [
      { label: copy.history.attendanceTotalLabel, value: selectedParticipantRow.attendanceTotal },
      { label: copy.history.checksOkLabel, value: selectedParticipantRow.attendanceOk },
      { label: copy.history.checksLateLabel, value: selectedParticipantRow.attendanceLate },
      { label: copy.history.checksMissedLabel, value: selectedParticipantRow.attendanceMissed },
      { label: copy.history.quizTotalLabel, value: selectedParticipantRow.quizTotal },
      { label: copy.history.quizOkLabel, value: selectedParticipantRow.quizOk },
      { label: copy.history.quizNokLabel, value: selectedParticipantRow.quizNok },
      { label: copy.history.quizLateLabel, value: selectedParticipantRow.quizLate },
      { label: copy.history.quizMissedLabel, value: selectedParticipantRow.quizMissed },
      { label: copy.history.chatMessages, value: selectedParticipantRow.chatCount },
      { label: copy.history.pollAnswers, value: selectedParticipantRow.pollAnswers },
      { label: copy.history.focusBlur, value: `${selectedParticipantRow.focusCount}/${selectedParticipantRow.blurCount}` },
      { label: copy.history.focusRate, value: `${selectedParticipantRow.focusRate}%` },
      { label: copy.history.checkPass, value: `${selectedParticipantRow.checkPassRate}%` },
      { label: copy.history.raiseHands, value: `${selectedParticipantRow.raiseHands}/${selectedParticipantRow.lowerHands}` },
      { label: copy.history.events, value: selectedParticipantRow.activityEvents },
    ] : [];

    const detailTabs = [
      {
        key: 'analytics',
        label: copy.history.analytics,
        rows: analyticsRows,
        meta: `${copy.history.onlineTime}: ${formatDuration(selectedParticipantRow?.onlineSeconds, language)}`,
      },
      {
        key: 'checks',
        label: copy.history.checks,
        rows: checksRows,
        meta: `${copy.history.checkPass}: ${selectedParticipantRow ? `${selectedParticipantRow.checkPassRate}%` : '-'}`,
      },
    ];

    const activeDetailTab = detailTabs.find((tab) => tab.key === participantDetailTab) || detailTabs[0];

    return (
      <BootstrapModal
        show={showParticipantModal}
        onHide={() => setShowParticipantModal(false)}
        centered
        size="lg"
        dialogClassName="ak-room-report-modal"
      >
        <BootstrapModal.Header closeButton>
          <BootstrapModal.Title>{copy.history.detailTitle}</BootstrapModal.Title>
        </BootstrapModal.Header>
        <BootstrapModal.Body>
          {!selectedParticipantRow && <InlineEmpty body={copy.history.noParticipantDetail} />}
          {!!selectedParticipantRow && (
            <>
              <section className="ak-room-participant-hero">
                <div className="ak-room-participant-hero-top">
                  <div>
                    <div className="ak-room-participant-eyebrow">{selectedParticipantRow.role || copy.history.participants}</div>
                    <h3>{selectedParticipantRow.user}</h3>
                    <p>{copy.history.detailSubtitle}</p>
                  </div>
                  <span className={`ak-room-badge ${selectedParticipantRow.statusClass}`}>{selectedParticipantRow.statusLabel}</span>
                </div>
                <div className="ak-room-participant-pill-row">
                  <span className="ak-room-report-meta">{copy.history.userIdLabel}: {selectedParticipantRow.userId || '-'}</span>
                </div>
              </section>

              <div className="ak-room-badge-row ak-room-participant-score-badges">
                <span className={`ak-room-badge ${scoreBadgeClass(selectedParticipantRow.attendanceScore)}`}>
                  {copy.history.attendanceScore}: {selectedParticipantRow.attendanceScore}%
                </span>
                <span className={`ak-room-badge ${scoreBadgeClass(participantAttentionScore)}`}>
                  {copy.history.attentionScore}: {participantAttentionScore}%
                </span>
                <span className={`ak-room-badge ${scoreBadgeClass(selectedParticipantRow.engagementScore)}`}>
                  {copy.history.engagementScore}: {selectedParticipantRow.engagementScore}%
                </span>
                <span className={`ak-room-badge ${scoreBadgeClass(selectedParticipantRow.activityScore)}`}>
                  {copy.history.activityMetric}: {selectedParticipantRow.activityScore}%
                </span>
                <span className={`ak-room-badge ${selectedParticipantRow.statusClass}`}>
                  {copy.history.status}: {selectedParticipantRow.statusLabel}
                </span>
              </div>

              <div
                className="ak-room-subtabs ak-room-participant-detail-tabs"
                role="tablist"
                aria-label={copy.history.detailTitle}
              >
                {detailTabs.map((tab) => (
                  <SubTab
                    key={tab.key}
                    active={participantDetailTab === tab.key}
                    label={tab.label}
                    onClick={() => setParticipantDetailTab(tab.key)}
                  />
                ))}
              </div>

              <section className="ak-room-surface">
                <div className="ak-room-surface-head">
                  <h3>{activeDetailTab.label}</h3>
                  <span className="ak-room-report-meta">{activeDetailTab.meta}</span>
                </div>
                <AttributeTable rows={activeDetailTab.rows} copy={copy.history} />
              </section>
            </>
          )}
        </BootstrapModal.Body>
      </BootstrapModal>
    );
  };

  const renderHistory = () => (
    <div className="ak-room-panel">
      <PanelHeader title={copy.history.title} body={copy.history.body} />
      {(sessionsStatus.message) && (
        <p className={`ak-room-status ${sessionsStatus.error ? 'is-error' : ''}`}>{sessionsStatus.message}</p>
      )}

      <div className="ak-room-subtabs">
        <SubTab active={historyView === 'meetings'} label={copy.history.tabs.meetings} onClick={() => setHistoryView('meetings')} />
        <SubTab active={historyView === 'recordings'} label={copy.history.tabs.recordings} onClick={() => setHistoryView('recordings')} />
      </div>

      {historyView === 'meetings' && (
        <section className="ak-room-surface">
          <div className="ak-room-surface-head">
            <h3>{copy.history.meetingsTitle}</h3>
          </div>
          <div className="ak-room-table-wrap">
            <table className="ak-room-table">
              <thead>
                <tr>
                  <th>{copy.history.date}</th>
                  <th>{copy.history.meeting}</th>
                  <th>{copy.history.users}</th>
                  <th>{copy.history.duration}</th>
                  <th>{copy.history.attendance}</th>
                  <th>{copy.sessions.action}</th>
                </tr>
              </thead>
              <tbody>
                {sessionsLoading && <tr><td colSpan="6">{copy.common.loading}</td></tr>}
                {!sessionsLoading && !pagedPastMeetings.length && <tr><td colSpan="6">{copy.history.noMeetings}</td></tr>}
                {!sessionsLoading && pagedPastMeetings.map((meeting) => (
                  <tr key={meeting.meeting_int_id}>
                    <td>{formatDateTime(meeting.created_at || meeting.started_at, language)}</td>
                    <td>{meeting.meeting_name || meeting.meeting_int_id || '-'}</td>
                    <td>{meeting.participants_count || 0}</td>
                    <td>{formatDuration(meeting.duration_seconds, language)}</td>
                    <td>
                      <div className="ak-room-badge-row">
                        <span className="ak-room-badge is-ok">{copy.history.ok} {meeting.attendance?.checks_ok || 0}</span>
                        <span className="ak-room-badge is-warn">{copy.history.late} {meeting.attendance?.checks_late || 0}</span>
                        <span className="ak-room-badge is-bad">{copy.history.missed} {meeting.attendance?.checks_missed || 0}</span>
                      </div>
                    </td>
                    <td>
                      <button
                        type="button"
                        className="ak-room-row-btn"
                        onClick={() => {
                          setSelectedMeeting(meeting.meeting_int_id);
                          setShowReportModal(true);
                        }}
                      >
                        {copy.history.details}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {!sessionsLoading && !!pastMeetings.length && (
            <TableFooter
              page={pastPage}
              rowsPerPage={pastRowsPerPage}
              totalItems={pastMeetings.length}
              onPageChange={setPastPage}
              onRowsChange={setPastRowsPerPage}
              copy={copy.common}
            />
          )}
        </section>
      )}

      {historyView === 'recordings' && (
        <section className="ak-room-surface">
          <div className="ak-room-surface-head">
            <h3>{copy.history.recordingsTitle}</h3>
          </div>
          {!showRecordings && <InlineEmpty body={copy.history.noRecordings} />}
          {showRecordings && (
            <>
              <div className="ak-room-table-wrap">
                <table className="ak-room-table">
                  <thead>
                    <tr>
                      <th>{copy.sessions.titleCol}</th>
                      <th>{copy.history.recordedAt}</th>
                      <th>{copy.history.duration}</th>
                      <th>{copy.history.users}</th>
                      <th>{copy.history.visibility}</th>
                      <th>{copy.history.formats}</th>
                      <th>{copy.history.options}</th>
                    </tr>
                  </thead>
                  <tbody>
                    {roomRecordings.isLoading && <tr><td colSpan="7">{copy.common.loading}</td></tr>}
                    {!roomRecordings.isLoading && !(roomRecordings.data?.data?.length) && <tr><td colSpan="7">{copy.history.noRecordings}</td></tr>}
                    {!roomRecordings.isLoading && roomRecordings.data?.data?.map((recording) => {
                      const firstPlayable = recording.formats?.[0];
                      return (
                        <tr key={recording.id}>
                          <td>{recording.name}</td>
                          <td>{formatDateTime(recording.recorded_at, language)}</td>
                          <td>{recording.length}</td>
                          <td>{recording.participants}</td>
                          <td>{recording.visibility}</td>
                          <td>
                            <div className="ak-room-inline-actions ak-room-inline-actions-wrap">
                              {(recording.formats || []).map((format) => (
                                <a
                                  key={`${recording.id}-${format.recording_type}`}
                                  href={format.url}
                                  target="_blank"
                                  rel="noreferrer"
                                  className="ak-room-link-btn ak-room-link-btn-inline"
                                >
                                  {format.recording_type}
                                </a>
                              ))}
                            </div>
                          </td>
                          <td>
                            {firstPlayable ? (
                              <a href={firstPlayable.url} target="_blank" rel="noreferrer" className="ak-room-row-btn">
                                {copy.history.open}
                              </a>
                            ) : '-'}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
              {!!(roomRecordings.data?.data?.length) && (
                <TableFooter
                  page={roomRecordings.data?.meta?.page || recordingsPage}
                  rowsPerPage={recordingsRowsPerPage}
                  totalItems={roomRecordings.data?.meta?.count || ((roomRecordings.data?.meta?.pages || 1) * (roomRecordings.data?.meta?.items || recordingsRowsPerPage))}
                  onPageChange={setRecordingsPage}
                  onRowsChange={setRecordingsRowsPerPage}
                  copy={copy.common}
                />
              )}
            </>
          )}
        </section>
      )}

    </div>
  );

  const renderFuture = () => (
    <div className="ak-room-panel">
      <PanelHeader
        title={copy.future.title}
        body={copy.future.body}
        action={(
          <button type="button" className="ak-room-primary-btn" onClick={() => setShowPlannerModal(true)}>
            {copy.future.button}
          </button>
        )}
      />
      {scheduleStatus.message && (
        <p className={`ak-room-status ${scheduleStatus.error ? 'is-error' : ''}`}>{scheduleStatus.message}</p>
      )}

      <section className="ak-room-surface">
        <div className="ak-room-surface-head">
          <h3>{copy.future.scheduleList}</h3>
          <a href={roomIcsHref} target="_blank" rel="noreferrer" className="ak-room-link-btn">
            {copy.future.roomIcs}
          </a>
        </div>
        <div className="ak-room-table-wrap">
          <table className="ak-room-table">
            <thead>
              <tr>
                <th>{copy.sessions.date}</th>
                <th>{copy.sessions.end}</th>
                <th>{copy.sessions.titleCol}</th>
                <th>{copy.sessions.status}</th>
                <th>{copy.sessions.action}</th>
              </tr>
            </thead>
            <tbody>
              {sessionsLoading && <tr><td colSpan="5">{copy.common.loading}</td></tr>}
              {!sessionsLoading && !pagedFutureMeetings.length && <tr><td colSpan="5">{copy.future.noFuture}</td></tr>}
              {!sessionsLoading && pagedFutureMeetings.map((meeting) => {
                const status = getFutureStatus(meeting, copy.sessions);
                return (
                  <tr key={meeting.id}>
                    <td>{formatDateTime(meeting.start_at, language)}</td>
                    <td>{formatDateTime(meeting.end_at, language)}</td>
                    <td>{meeting.title || meeting.meeting_name || friendlyId}</td>
                    <td><span className={`ak-room-table-badge ${status.className}`}>{status.label}</span></td>
                    <td>
                      <div className="ak-room-inline-actions ak-room-inline-actions-wrap">
                        {status.key === 'scheduled' && (
                          <>
                            <button type="button" className="ak-room-row-btn" onClick={() => startFutureMeetingNow(meeting)}>
                              {copy.future.startNow}
                            </button>
                            <button type="button" className="ak-room-row-btn" onClick={() => cancelFutureMeeting(meeting.id)}>
                              {copy.future.cancel}
                            </button>
                          </>
                        )}
                        {status.key === 'ongoing' && meeting.join_url && (
                          <a href={meeting.join_url} target="_blank" rel="noreferrer" className="ak-room-row-btn">
                            {copy.sessions.open}
                          </a>
                        )}
                        {status.key === 'completed' && (
                          <span className="text-muted small">-</span>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
        {!sessionsLoading && !!futureMeetings.length && (
          <TableFooter
            page={futurePage}
            rowsPerPage={futureRowsPerPage}
            totalItems={futureMeetings.length}
            onPageChange={setFuturePage}
            onRowsChange={setFutureRowsPerPage}
            copy={copy.common}
          />
        )}
      </section>

      <BootstrapModal show={showPlannerModal} onHide={() => setShowPlannerModal(false)} centered size="lg">
        <BootstrapModal.Header closeButton>
          <BootstrapModal.Title>{copy.future.formTitle}</BootstrapModal.Title>
        </BootstrapModal.Header>
        <BootstrapModal.Body>
          <form className="ak-room-form-grid" onSubmit={createFutureMeeting}>
            <label className="ak-room-field ak-room-field-span-2">
              <span>{copy.future.titleLabel}</span>
              <input className="ak-room-input" value={form.title} onChange={(event) => setField('title', event.target.value)} />
            </label>
            <label className="ak-room-field ak-room-field-span-2">
              <span>{copy.future.description}</span>
              <textarea className="ak-room-textarea" value={form.description} onChange={(event) => setField('description', event.target.value)} />
            </label>
            <label className="ak-room-field">
              <span>{copy.future.start}</span>
              <input type="datetime-local" className="ak-room-input" value={form.startAt} onChange={(event) => setField('startAt', event.target.value)} />
            </label>
            <label className="ak-room-field">
              <span>{copy.future.end}</span>
              <input type="datetime-local" className="ak-room-input" value={form.endAt} onChange={(event) => setField('endAt', event.target.value)} />
            </label>
            <label className="ak-room-field ak-room-field-span-2">
              <span>{copy.future.timezone}</span>
              <input className="ak-room-input" value={form.timezone} onChange={(event) => setField('timezone', event.target.value)} />
            </label>
            <div className="ak-room-inline-actions ak-room-field-span-2">
              <button type="submit" className="ak-room-primary-btn">{copy.future.create}</button>
              <button type="button" className="ak-room-link-btn" onClick={() => setShowPlannerModal(false)}>{copy.common.close}</button>
            </div>
          </form>
        </BootstrapModal.Body>
      </BootstrapModal>
    </div>
  );

  const renderFiles = () => (
    <div className="ak-room-panel">
      <PanelHeader title={copy.files.title} body={copy.files.body} />
      <section className="ak-room-surface">
        {isConfigLoading && <InlineEmpty body={copy.common.loading} />}
        {!isConfigLoading && settings?.PreuploadPresentation && <Presentation />}
        {!isConfigLoading && !settings?.PreuploadPresentation && <InlineEmpty body={copy.files.disabled} />}
      </section>
    </div>
  );

  const renderAccess = () => (
    <div className="ak-room-panel">
      <PanelHeader title={copy.access.title} body={copy.access.body} />
      <section className="ak-room-surface">
        {isConfigLoading && <InlineEmpty body={copy.common.loading} />}
        {!isConfigLoading && settings?.ShareRooms && <SharedAccess />}
        {!isConfigLoading && !settings?.ShareRooms && <InlineEmpty body={copy.access.disabled} />}
      </section>
    </div>
  );

  const renderSettings = () => (
    <div className="ak-room-panel">
      <PanelHeader title={copy.settings.title} body={copy.settings.body} />
      <section className="ak-room-surface">
        <RoomSettings />
      </section>
    </div>
  );

  return (
    <div className="ak-room-workspace">
      <div className="ak-room-tabs" role="tablist" aria-label="Room detail tabs">
        {tabConfig.map((tab) => (
          <DetailTab
            key={tab.key}
            active={activeTab === tab.key}
            label={tab.label}
            icon={tab.icon}
            onClick={() => setActiveTab(tab.key)}
          />
        ))}
      </div>

      {activeTab === 'overview' && renderOverview()}
      {activeTab === 'sessions' && renderAllSessions()}
      {activeTab === 'history' && renderHistory()}
      {activeTab === 'future' && renderFuture()}
      {activeTab === 'files' && renderFiles()}
      {activeTab === 'access' && renderAccess()}
      {activeTab === 'settings' && renderSettings()}
      {renderMeetingReportModal()}
      {renderParticipantDetailModal()}
    </div>
  );
}
