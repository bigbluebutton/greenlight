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

import React, {
  useCallback, useEffect, useMemo, useState,
} from 'react';
import {
  AdjustmentsHorizontalIcon,
  ArrowTopRightOnSquareIcon,
  CalendarDaysIcon,
  ChartBarIcon,
  ClockIcon,
  DocumentDuplicateIcon,
  HomeIcon,
  IdentificationIcon,
  LinkIcon,
  Square2StackIcon,
  VideoCameraIcon,
} from '@heroicons/react/24/outline';
import {
  Card,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../../contexts/auth/AuthProvider';
import PermissionChecker from '../../helpers/PermissionChecker';
import useRecordingsCount from '../../hooks/queries/recordings/useRecordingsCount';
import useRoomConfigValue from '../../hooks/queries/rooms/useRoomConfigValue';
import useRooms from '../../hooks/queries/rooms/useRooms';
import UserRecordings from '../recordings/UserRecordings';
import RoomsList from './RoomsList';

const WORKSPACE_COPY = {
  en: {
    tabs: {
      overview: 'Overview',
      rooms: 'Rooms',
      courses: 'Courses',
      recordings: 'Recordings',
      schedule: 'Schedule',
      analytics: 'Analytics',
      admin: 'Admin',
    },
    persona: {
      admin: 'Admin Workspace',
      instructor: 'Instructor Workspace',
      user: 'Personal Workspace',
    },
    summaries: {
      admin: 'Global controls and audits.',
      instructor: 'Rooms, schedule, and recordings.',
      user: 'Sessions and access.',
    },
    workspace: {
      eyebrow: 'Operations Workspace',
      title: 'Akademio Live Control Center',
      body: 'Role-based access to rooms, recordings, scheduling, analytics, and admin tools.',
      roleScope: 'Current access scope',
      quickActions: 'Quick actions',
      phaseNote: '',
    },
    visuals: {
      title: 'Visual Snapshot',
      occupancy: 'Live ratio',
      breakdown: 'Room State',
      live: 'Live',
      idle: 'Idle',
      shared: 'Shared',
      access: 'Access',
      recordingsOn: 'Recording on',
      recordingsOff: 'Recording off',
      stateOn: 'On',
      stateOff: 'Off',
    },
    insights: {
      trend: 'Meeting Trend',
      topRooms: 'Top Active Rooms',
      noTrend: 'No recent meetings.',
      noRooms: 'No room activity yet.',
      users: 'users',
      sessions: 'sessions',
    },
    recordingsDetail: {
      title: 'Evidence Drill-Down',
      room: 'Room',
      selectRoom: 'Select room',
      meetings: 'Past Meetings',
      noMeetings: 'No past meetings.',
      users: 'Per-user Evidence',
      noUsers: 'Select a meeting.',
      loading: 'Loading...',
      date: 'Date',
      meeting: 'Meeting',
      usersCount: 'Users',
      duration: 'Duration',
      attendance: 'Attendance',
      user: 'User',
      role: 'Role',
      checks: 'Checks',
      ok: 'OK',
      late: 'Late',
      missed: 'Missed',
      details: 'Details',
      exportCsv: 'Export CSV',
      exportJson: 'Export JSON',
      recording: 'Recording',
      open: 'Open',
    },
    adminWidgets: {
      logs: 'Logs Loaded',
      actors: 'Actors',
      exports: 'Exports',
      schedule: 'Scheduling',
      presets: 'Presets',
      presetExport: 'Exports',
      presetSchedule: 'Scheduling',
      presetAttendance: 'Attendance',
      presetAdmin: 'Admin',
    },
    adminControls: {
      roomRules: 'Room Rules',
      liveControls: 'Live Controls',
      room: 'Room',
      selectRoom: 'Select room',
      meeting: 'Meeting',
      selectMeeting: 'Select meeting',
      enabled: 'Enabled',
      interval: 'Interval',
      jitter: 'Jitter',
      ttl: 'TTL',
      maxMissed: 'Max missed',
      updatedBy: 'Updated by',
      load: 'Load',
      save: 'Save',
      attendanceTtl: 'Attendance TTL',
      issueAttendance: 'Issue Attendance',
      quizPrompt: 'Quiz prompt',
      quizExpected: 'Expected answer',
      quizTtl: 'Quiz TTL',
      issueQuiz: 'Issue Quiz',
      requiredRoom: 'Select a room.',
      requiredMeeting: 'Select a meeting.',
      requiredQuiz: 'Prompt and expected answer are required.',
      roomRulesLoaded: 'Room rules loaded.',
      roomRulesSaved: 'Room rules saved.',
      roomRulesError: 'Room rules request failed.',
      liveLoaded: 'Live controls loaded.',
      liveSaved: 'Live controls saved.',
      liveError: 'Live controls request failed.',
      issueDone: 'Check issued.',
      issueError: 'Issue request failed.',
    },
    metrics: {
      totalRooms: 'Total Rooms',
      liveNow: 'Live Now',
      recordings: 'Recordings',
      shared: 'Shared Access',
    },
    roomsPanel: {
      title: 'Rooms and Courses',
      body: 'Manage active rooms and courses.',
    },
    recordingsPanel: {
      title: 'Past Sessions and Evidence',
      body: 'Review recordings and exports.',
    },
    schedulePanel: {
      title: 'Future Meetings and Scheduling',
      body: 'Plan future meetings and ICS feeds.',
      cards: [
        {
          title: 'Future Meeting Planner',
          body: '',
        },
        {
          title: 'Review Live Rooms',
          body: '',
          view: 'rooms',
        },
      ],
    },
    analyticsPanel: {
      title: 'Analytics and Compliance',
      body: 'Engagement, scoring, exports, and audit insight.',
      cards: [
        {
          title: 'Learning Analytics Dashboard',
          body: '',
          href: '/learning-analytics-dashboard/',
        },
        {
          title: 'Compliance Widgets',
          body: '',
        },
      ],
    },
    adminPanel: {
      title: 'Admin and Audit Controls',
      body: 'Privileged controls and audits.',
      cards: [
        {
          title: 'User Management',
          body: '',
          href: '/admin/users',
        },
        {
          title: 'Server Rooms',
          body: '',
          href: '/admin/server_rooms',
        },
        {
          title: 'Server Recordings',
          body: '',
          href: '/admin/server_recordings',
        },
        {
          title: 'Profile Settings',
          body: '',
          href: '/profile',
        },
      ],
    },
    shortcuts: {
      rooms: 'Open room operations',
      recordings: 'Review recordings',
      schedule: 'Plan future sessions',
      analytics: 'Open analytics',
      admin: 'Open admin controls',
    },
    access: {
      create: 'Room creation',
      recordings: 'Recordings workflow',
      manageRooms: 'Room governance',
      manageUsers: 'User administration',
      manageSettings: 'Platform settings',
      shared: 'Shared room visibility',
    },
  },
  tr: {
    tabs: {
      overview: 'Genel Bakis',
      rooms: 'Odalar',
      courses: 'Kurslar',
      recordings: 'Kayitlar',
      schedule: 'Planlama',
      analytics: 'Analitik',
      admin: 'Yonetim',
    },
    persona: {
      admin: 'Yonetim Alani',
      instructor: 'Egitmen Alani',
      user: 'Kisisel Alan',
    },
    summaries: {
      admin: 'Genel kontroller ve denetim.',
      instructor: 'Odalar, planlama ve kayitlar.',
      user: 'Oturumlar ve erisim.',
    },
    workspace: {
      eyebrow: 'Operasyon Alani',
      title: 'Akademio Live Kontrol Merkezi',
      body: 'Odalar, kayitlar, planlama, analitik ve yonetim icin rol bazli alan.',
      roleScope: 'Mevcut erisim alani',
      quickActions: 'Hizli islemler',
      phaseNote: '',
    },
    visuals: {
      title: 'Gorsel Ozet',
      occupancy: 'Canli oran',
      breakdown: 'Oda Durumu',
      live: 'Canli',
      idle: 'Bos',
      shared: 'Paylasimli',
      access: 'Erisim',
      recordingsOn: 'Kayit acik',
      recordingsOff: 'Kayit kapali',
      stateOn: 'Acik',
      stateOff: 'Kapali',
    },
    insights: {
      trend: 'Toplanti Trendi',
      topRooms: 'En Aktif Odalar',
      noTrend: 'Yeni toplanti yok.',
      noRooms: 'Oda etkinligi yok.',
      users: 'kullanici',
      sessions: 'oturum',
    },
    recordingsDetail: {
      title: 'Kanit Inceleme',
      room: 'Oda',
      selectRoom: 'Oda secin',
      meetings: 'Gecmis Toplantilar',
      noMeetings: 'Gecmis toplanti yok.',
      users: 'Kullanici Kanitlari',
      noUsers: 'Toplanti secin.',
      loading: 'Yukleniyor...',
      date: 'Tarih',
      meeting: 'Toplanti',
      usersCount: 'Kullanici',
      duration: 'Sure',
      attendance: 'Katilim',
      user: 'Kullanici',
      role: 'Rol',
      checks: 'Kontrol',
      ok: 'OK',
      late: 'Gec',
      missed: 'Kacirildi',
      details: 'Detay',
      exportCsv: 'CSV Disa Aktar',
      exportJson: 'JSON Disa Aktar',
      recording: 'Kayit',
      open: 'Ac',
    },
    adminWidgets: {
      logs: 'Yuklenen Log',
      actors: 'Aktif Aktor',
      exports: 'Disa Aktarim',
      schedule: 'Planlama',
      presets: 'Hazir Filtreler',
      presetExport: 'Disa Aktarim',
      presetSchedule: 'Planlama',
      presetAttendance: 'Yoklama',
      presetAdmin: 'Yonetim',
    },
    adminControls: {
      roomRules: 'Oda Kurallari',
      liveControls: 'Canli Kontroller',
      room: 'Oda',
      selectRoom: 'Oda secin',
      meeting: 'Toplanti',
      selectMeeting: 'Toplanti secin',
      enabled: 'Aktif',
      interval: 'Aralik',
      jitter: 'Jitter',
      ttl: 'TTL',
      maxMissed: 'Maks kacirma',
      updatedBy: 'Guncelleyen',
      load: 'Yukle',
      save: 'Kaydet',
      attendanceTtl: 'Yoklama TTL',
      issueAttendance: 'Yoklama Gonder',
      quizPrompt: 'Quiz sorusu',
      quizExpected: 'Beklenen cevap',
      quizTtl: 'Quiz TTL',
      issueQuiz: 'Quiz Gonder',
      requiredRoom: 'Oda secin.',
      requiredMeeting: 'Toplanti secin.',
      requiredQuiz: 'Soru ve beklenen cevap gerekli.',
      roomRulesLoaded: 'Oda kurallari yuklendi.',
      roomRulesSaved: 'Oda kurallari kaydedildi.',
      roomRulesError: 'Oda kurallari istegi basarisiz.',
      liveLoaded: 'Canli kontroller yuklendi.',
      liveSaved: 'Canli kontroller kaydedildi.',
      liveError: 'Canli kontrol istegi basarisiz.',
      issueDone: 'Kontrol gonderildi.',
      issueError: 'Gonderim istegi basarisiz.',
    },
    metrics: {
      totalRooms: 'Toplam Oda',
      liveNow: 'Canli',
      recordings: 'Kayitlar',
      shared: 'Paylasimli',
    },
    roomsPanel: {
      title: 'Odalar ve Kurslar',
      body: 'Aktif odalari ve kurslari yonetin.',
    },
    recordingsPanel: {
      title: 'Gecmis Oturumlar ve Kanitlar',
      body: 'Kayitlari ve ciktilari yonetin.',
    },
    schedulePanel: {
      title: 'Gelecek Toplantilar ve Planlama',
      body: 'Gelecek toplantilari ve ICS beslemelerini yonetin.',
      cards: [
        {
          title: 'Toplanti Planlayici',
          body: '',
        },
        {
          title: 'Canli Odalara Don',
          body: '',
          view: 'rooms',
        },
      ],
    },
    analyticsPanel: {
      title: 'Analitik ve Uyumluluk',
      body: 'Etkilesim, skorlar, ciktilar ve denetim gorunumu.',
      cards: [
        {
          title: 'Ogrenme Analitigi',
          body: '',
          href: '/learning-analytics-dashboard/',
        },
        {
          title: 'Uyumluluk Bilesenleri',
          body: '',
        },
      ],
    },
    adminPanel: {
      title: 'Yonetim ve Denetim Kontrolleri',
      body: 'Yetkili kontroller ve denetim.',
      cards: [
        {
          title: 'Kullanici Yonetimi',
          body: '',
          href: '/admin/users',
        },
        {
          title: 'Sunucu Odalari',
          body: '',
          href: '/admin/server_rooms',
        },
        {
          title: 'Sunucu Kayitlari',
          body: '',
          href: '/admin/server_recordings',
        },
        {
          title: 'Profil Ayarlari',
          body: '',
          href: '/profile',
        },
      ],
    },
    shortcuts: {
      rooms: 'Oda operasyonlari',
      recordings: 'Kayitlari incele',
      schedule: 'Gelecek oturumlari planla',
      analytics: 'Analitigi ac',
      admin: 'Yonetim kontrolleri',
    },
    access: {
      create: 'Oda olusturma',
      recordings: 'Kayit akis',
      manageRooms: 'Oda yonetimi',
      manageUsers: 'Kullanici yonetimi',
      manageSettings: 'Platform ayarlari',
      shared: 'Paylasimli oda gorunurlugu',
    },
  },
};

function WorkspaceTab({ active, icon: Icon, label, onClick }) {
  return (
    <button
      type="button"
      role="tab"
      aria-selected={active}
      className={`ak-workspace-tab ${active ? 'is-active' : ''}`}
      onClick={onClick}
    >
      <Icon className="ak-workspace-tab-icon" aria-hidden="true" />
      <span>{label}</span>
    </button>
  );
}

function MetricCard({
  accent, icon: Icon, label, value, helper,
}) {
  return (
    <Card className={`ak-workspace-metric ak-workspace-metric-${accent}`}>
      <Card.Body>
        <div className="ak-workspace-metric-top">
          <span className="ak-workspace-metric-label">{label}</span>
          <Icon className="ak-workspace-metric-icon" aria-hidden="true" />
        </div>
        <div className="ak-workspace-metric-value">{value}</div>
        <div className="ak-workspace-metric-helper">{helper}</div>
      </Card.Body>
    </Card>
  );
}

function ActionCard({
  title,
  body,
  icon: Icon,
  href,
  onClick,
  accent = 'default',
}) {
  const content = (
    <>
      <div className="ak-workspace-action-head">
        <span className={`ak-workspace-action-icon ak-workspace-action-icon-${accent}`}>
          <Icon aria-hidden="true" />
        </span>
        <ArrowTopRightOnSquareIcon className="ak-workspace-action-arrow" aria-hidden="true" />
      </div>
      <h3>{title}</h3>
      {body && <p>{body}</p>}
    </>
  );

  if (href) {
    return (
      <a href={href} className="ak-workspace-action-card">
        {content}
      </a>
    );
  }

  return (
    <button type="button" className="ak-workspace-action-card" onClick={onClick}>
      {content}
    </button>
  );
}

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

function normalizeExtError(error) {
  if (error instanceof Error && error.message) return error.message;
  return 'Request failed.';
}

async function fetchExtJson(path, options = {}) {
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

function useExtRooms() {
  const [rooms, setRooms] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let active = true;

    const load = async () => {
      setLoading(true);
      setError('');
      try {
        const data = await fetchExtJson('/ext/rooms?limit=500');
        if (!active) return;
        const normalizedRooms = (data.rooms || [])
          .map((roomItem) => {
            if (typeof roomItem === 'string') {
              return {
                id: roomItem,
                label: roomItem,
                sessionsCount: 0,
              };
            }

            if (roomItem && typeof roomItem === 'object') {
              const roomId = roomItem.room || roomItem.id || '';
              if (!roomId) return null;
              return {
                id: roomId,
                label: `${roomId} (${roomItem.sessions_count || 0})`,
                sessionsCount: roomItem.sessions_count || 0,
              };
            }

            return null;
          })
          .filter(Boolean);
        setRooms(normalizedRooms);
      } catch (err) {
        if (!active) return;
        setRooms([]);
        setError(normalizeExtError(err));
      } finally {
        if (active) setLoading(false);
      }
    };

    load();

    return () => {
      active = false;
    };
  }, []);

  return { rooms, loading, error };
}

function ScheduleWorkspace({ copy, language, actorName }) {
  const { rooms, loading: roomsLoading, error: roomsError } = useExtRooms();
  const [selectedRoom, setSelectedRoom] = useState('');
  const [futureMeetings, setFutureMeetings] = useState([]);
  const [status, setStatus] = useState({ message: '', error: false });
  const [loadingFuture, setLoadingFuture] = useState(false);
  const [form, setForm] = useState({
    title: '',
    description: '',
    startAt: '',
    endAt: '',
    timezone: 'Europe/Istanbul',
  });

  useEffect(() => {
    if (!selectedRoom && rooms.length) {
      setSelectedRoom(rooms[0].id);
    }
  }, [rooms, selectedRoom]);

  useEffect(() => {
    let active = true;

    const loadFuture = async () => {
      if (!selectedRoom) {
        setFutureMeetings([]);
        return;
      }

      setLoadingFuture(true);
      try {
        const data = await fetchExtJson(`/ext/future-meetings?room=${encodeURIComponent(selectedRoom)}&limit=50&includePast=1`);
        if (!active) return;
        setFutureMeetings(data.future_meetings || []);
        setStatus({ message: `${data.future_meetings?.length || 0} scheduled meeting(s) loaded.`, error: false });
      } catch (err) {
        if (!active) return;
        setFutureMeetings([]);
        setStatus({ message: normalizeExtError(err), error: true });
      } finally {
        if (active) setLoadingFuture(false);
      }
    };

    loadFuture();

    return () => {
      active = false;
    };
  }, [selectedRoom]);

  const setField = (key, value) => {
    setForm((prev) => ({ ...prev, [key]: value }));
  };

  const createMeeting = async (event) => {
    event.preventDefault();
    if (!selectedRoom || !form.startAt || !form.endAt || !form.title.trim()) {
      setStatus({ message: 'Room, title, start, and end are required.', error: true });
      return;
    }

    try {
      await fetchExtJson('/ext/future-meetings/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          room: selectedRoom,
          title: form.title.trim(),
          description: form.description.trim(),
          start_at: new Date(form.startAt).toISOString(),
          end_at: new Date(form.endAt).toISOString(),
          timezone: form.timezone || 'Europe/Istanbul',
          created_by: actorName,
          metadata: { source: 'greenlight-workspace' },
        }),
      });

      setStatus({ message: 'Future meeting created.', error: false });
      setForm((prev) => ({ ...prev, title: '', description: '', startAt: '', endAt: '' }));
      const data = await fetchExtJson(`/ext/future-meetings?room=${encodeURIComponent(selectedRoom)}&limit=50&includePast=1`);
      setFutureMeetings(data.future_meetings || []);
    } catch (err) {
      setStatus({ message: normalizeExtError(err), error: true });
    }
  };

  const cancelMeeting = async (id) => {
    try {
      await fetchExtJson('/ext/future-meetings/cancel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: String(id) }),
      });
      setStatus({ message: 'Future meeting cancelled.', error: false });
      const data = await fetchExtJson(`/ext/future-meetings?room=${encodeURIComponent(selectedRoom)}&limit=50&includePast=1`);
      setFutureMeetings(data.future_meetings || []);
    } catch (err) {
      setStatus({ message: normalizeExtError(err), error: true });
    }
  };

  const roomIcsHref = selectedRoom ? `/ext/future-meetings/ics?room=${encodeURIComponent(selectedRoom)}` : '';

  return (
    <div className="ak-workspace-panel">
      <PanelIntro eyebrow={copy.tabs.schedule} title={copy.schedulePanel.title} body={copy.schedulePanel.body} />

      <div className="ak-workspace-tool-grid ak-workspace-tool-grid-2">
        <section className="ak-workspace-tool-card">
          <div className="ak-workspace-tool-head">
            <h3>{copy.schedulePanel.cards[0].title}</h3>
            <p>{copy.schedulePanel.cards[0].body}</p>
          </div>

          <form className="ak-workspace-form-grid" onSubmit={createMeeting}>
            <label className="ak-workspace-field">
              <span>Room</span>
              <select className="ak-workspace-select" value={selectedRoom} onChange={(event) => setSelectedRoom(event.target.value)}>
                <option value="">{roomsLoading ? 'Loading rooms...' : 'Select room'}</option>
                {rooms.map((room) => <option key={room.id} value={room.id}>{room.label}</option>)}
              </select>
            </label>

            <label className="ak-workspace-field">
              <span>Timezone</span>
              <input className="ak-workspace-input" value={form.timezone} onChange={(event) => setField('timezone', event.target.value)} />
            </label>

            <label className="ak-workspace-field ak-workspace-field-span-2">
              <span>Title</span>
              <input className="ak-workspace-input" value={form.title} onChange={(event) => setField('title', event.target.value)} />
            </label>

            <label className="ak-workspace-field ak-workspace-field-span-2">
              <span>Description</span>
              <textarea className="ak-workspace-textarea" value={form.description} onChange={(event) => setField('description', event.target.value)} />
            </label>

            <label className="ak-workspace-field">
              <span>Start</span>
              <input type="datetime-local" className="ak-workspace-input" value={form.startAt} onChange={(event) => setField('startAt', event.target.value)} />
            </label>

            <label className="ak-workspace-field">
              <span>End</span>
              <input type="datetime-local" className="ak-workspace-input" value={form.endAt} onChange={(event) => setField('endAt', event.target.value)} />
            </label>

            <div className="ak-workspace-inline-actions ak-workspace-field-span-2">
              <button type="submit" className="ak-workspace-primary-btn">Create Meeting</button>
              <a href="/ext/future-meetings/ics/all" className="ak-workspace-link-btn" target="_blank" rel="noreferrer">Global ICS</a>
              {roomIcsHref && <a href={roomIcsHref} className="ak-workspace-link-btn" target="_blank" rel="noreferrer">Room ICS</a>}
            </div>
          </form>
          {(roomsError || status.message) && (
            <p className={`ak-workspace-status ${status.error || roomsError ? 'is-error' : ''}`}>
              {roomsError || status.message}
            </p>
          )}
        </section>

        <section className="ak-workspace-tool-card">
          <div className="ak-workspace-tool-head">
            <h3>Upcoming Sessions</h3>
          </div>

          <div className="ak-workspace-table-wrap">
            <table className="ak-workspace-table">
              <thead>
                <tr>
                  <th>Start</th>
                  <th>End</th>
                  <th>Title</th>
                  <th>Join</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {loadingFuture && (
                  <tr><td colSpan="5">Loading...</td></tr>
                )}
                {!loadingFuture && !futureMeetings.length && (
                  <tr><td colSpan="5">No scheduled meetings.</td></tr>
                )}
                {!loadingFuture && futureMeetings.map((meeting) => (
                  <tr key={meeting.id}>
                    <td>{formatDateTime(meeting.start_at, language)}</td>
                    <td>{formatDateTime(meeting.end_at, language)}</td>
                    <td>{meeting.title || '-'}</td>
                    <td>
                      {meeting.join_url ? (
                        <a href={meeting.join_url} target="_blank" rel="noreferrer" className="ak-workspace-inline-link">Open</a>
                      ) : '-'}
                    </td>
                    <td>
                      <button type="button" className="ak-workspace-row-btn" onClick={() => cancelMeeting(meeting.id)}>Cancel</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
  );
}

function AnalyticsWorkspace({ copy, language }) {
  const { rooms, loading: roomsLoading } = useExtRooms();
  const [selectedRoom, setSelectedRoom] = useState('');
  const [recentMeetings, setRecentMeetings] = useState([]);
  const [selectedMeeting, setSelectedMeeting] = useState('');
  const [timelineLimit, setTimelineLimit] = useState('100');
  const [eventTypes, setEventTypes] = useState('');
  const [reloadKey, setReloadKey] = useState(0);
  const [loadingMeetings, setLoadingMeetings] = useState(false);
  const [loadingData, setLoadingData] = useState(false);
  const [status, setStatus] = useState({ message: '', error: false });
  const [analytics, setAnalytics] = useState({
    summary: null,
    timeline: [],
    attention: [],
  });

  useEffect(() => {
    let active = true;

    const loadMeetings = async () => {
      setLoadingMeetings(true);
      try {
        const params = new URLSearchParams();
        params.set('limit', '150');
        params.set('includeEnded', '1');
        if (selectedRoom) params.set('room', selectedRoom);
        const data = await fetchExtJson(`/ext/recent-meetings?${params.toString()}`);
        if (!active) return;
        const meetings = data.meetings || [];
        setRecentMeetings(meetings);
        setSelectedMeeting((prev) => {
          if (prev && meetings.find((meeting) => meeting.meeting_int_id === prev)) return prev;
          return meetings[0]?.meeting_int_id || '';
        });
      } catch (err) {
        if (!active) return;
        setRecentMeetings([]);
        setSelectedMeeting('');
        setStatus({ message: normalizeExtError(err), error: true });
      } finally {
        if (active) setLoadingMeetings(false);
      }
    };

    loadMeetings();

    return () => {
      active = false;
    };
  }, [selectedRoom]);

  useEffect(() => {
    let active = true;

    const loadAnalytics = async () => {
      if (!selectedMeeting) {
        setAnalytics({ summary: null, timeline: [], attention: [] });
        return;
      }

      setLoadingData(true);
      try {
        const params = new URLSearchParams();
        params.set('meeting_int_id', selectedMeeting);
        params.set('limit', String(Math.min(Math.max(parseInt(timelineLimit, 10) || 100, 1), 3000)));
        if (eventTypes.trim()) params.set('types', eventTypes.trim());

        const [summary, timeline, attention] = await Promise.all([
          fetchExtJson(`/ext/engagement-summary?meeting_int_id=${encodeURIComponent(selectedMeeting)}`),
          fetchExtJson(`/ext/engagement-timeline?${params.toString()}`),
          fetchExtJson(`/ext/attention-score?meeting_int_id=${encodeURIComponent(selectedMeeting)}&limit=500`),
        ]);

        if (!active) return;
        setAnalytics({
          summary,
          timeline: timeline.events || [],
          attention: attention.users || [],
        });
        setStatus({ message: 'Analytics loaded.', error: false });
      } catch (err) {
        if (!active) return;
        setAnalytics({ summary: null, timeline: [], attention: [] });
        setStatus({ message: normalizeExtError(err), error: true });
      } finally {
        if (active) setLoadingData(false);
      }
    };

    loadAnalytics();

    return () => {
      active = false;
    };
  }, [selectedMeeting, reloadKey]);

  const summary = analytics.summary || {};
  const meeting = summary.meeting || {};
  const attendance = summary.attendance || {};
  const engagement = summary.engagement || {};
  const exportCsvHref = selectedMeeting ? `/ext/export/attendance.csv?meeting_int_id=${encodeURIComponent(selectedMeeting)}&includeChecks=1` : '';
  const exportJsonHref = selectedMeeting ? `/ext/export/attendance.json?meeting_int_id=${encodeURIComponent(selectedMeeting)}&includeChecks=1` : '';

  return (
    <div className="ak-workspace-panel">
      <PanelIntro eyebrow={copy.tabs.analytics} title={copy.analyticsPanel.title} body={copy.analyticsPanel.body} />

      <div className="ak-workspace-tool-card ak-workspace-tool-card-tight">
        <div className="ak-workspace-form-grid ak-workspace-form-grid-analytics">
          <label className="ak-workspace-field">
            <span>Room</span>
            <select className="ak-workspace-select" value={selectedRoom} onChange={(event) => setSelectedRoom(event.target.value)}>
              <option value="">{roomsLoading ? 'Loading rooms...' : 'All rooms'}</option>
              {rooms.map((room) => <option key={room.id} value={room.id}>{room.label}</option>)}
            </select>
          </label>
          <label className="ak-workspace-field ak-workspace-field-grow">
            <span>Meeting</span>
            <select className="ak-workspace-select" value={selectedMeeting} onChange={(event) => setSelectedMeeting(event.target.value)}>
              <option value="">{loadingMeetings ? 'Loading meetings...' : 'Select meeting'}</option>
              {recentMeetings.map((meetingItem) => (
                <option key={meetingItem.meeting_int_id} value={meetingItem.meeting_int_id}>
                  {meetingItem.meeting_name || meetingItem.meeting_int_id}
                </option>
              ))}
            </select>
          </label>
          <label className="ak-workspace-field">
            <span>Timeline limit</span>
            <input type="number" min="1" max="3000" className="ak-workspace-input" value={timelineLimit} onChange={(event) => setTimelineLimit(event.target.value)} />
          </label>
          <label className="ak-workspace-field ak-workspace-field-grow">
            <span>Event types</span>
            <input className="ak-workspace-input" placeholder="join,leave,chat" value={eventTypes} onChange={(event) => setEventTypes(event.target.value)} />
          </label>
          <div className="ak-workspace-inline-actions">
            <button type="button" className="ak-workspace-primary-btn" onClick={() => setReloadKey((prev) => prev + 1)}>Reload Analytics</button>
          </div>
        </div>
        {(status.message || loadingData) && (
          <p className={`ak-workspace-status ${status.error ? 'is-error' : ''}`}>
            {loadingData ? 'Loading analytics...' : status.message}
          </p>
        )}
      </div>

      <div className="ak-workspace-tool-grid ak-workspace-tool-grid-3 ak-workspace-tool-grid-gap-top">
        <MetricCard accent="red" icon={ChartBarIcon} label="Participants" value={attendance.participants_count || 0} helper={meeting.meeting_name || 'Meeting scope'} />
        <MetricCard accent="blue" icon={ClockIcon} label="Checks" value={`${attendance.checks_ok || 0}/${attendance.checks_late || 0}/${attendance.checks_missed || 0}`} helper="ok / late / missed" />
        <MetricCard accent="slate" icon={DocumentDuplicateIcon} label="Events" value={engagement.events_total || 0} helper="timeline events" />
      </div>

      <div className="ak-workspace-inline-actions ak-workspace-inline-actions-top">
        {exportCsvHref && <a href={exportCsvHref} target="_blank" rel="noreferrer" className="ak-workspace-link-btn">Export CSV</a>}
        {exportJsonHref && <a href={exportJsonHref} target="_blank" rel="noreferrer" className="ak-workspace-link-btn">Export JSON</a>}
        <a href="/learning-analytics-dashboard/" className="ak-workspace-link-btn">Open Native Analytics</a>
      </div>

      <div className="ak-workspace-tool-grid ak-workspace-tool-grid-2 ak-workspace-tool-grid-gap-top">
        <section className="ak-workspace-tool-card">
          <div className="ak-workspace-tool-head">
            <h3>Engagement Timeline</h3>
          </div>
          <div className="ak-workspace-table-wrap">
            <table className="ak-workspace-table">
              <thead>
                <tr>
                  <th>Time</th>
                  <th>Type</th>
                  <th>User</th>
                  <th>Role</th>
                  <th>Detail</th>
                </tr>
              </thead>
              <tbody>
                {!loadingData && !analytics.timeline.length && <tr><td colSpan="5">No timeline data.</td></tr>}
                {analytics.timeline.map((event) => (
                  <tr key={`${event.event_at}-${event.user_id}-${event.event_type}`}>
                    <td>{formatDateTime(event.event_at, language)}</td>
                    <td>{event.event_type || '-'}</td>
                    <td>{event.name || event.user_id || '-'}</td>
                    <td>{event.role || '-'}</td>
                    <td>{event.message || event.event_name || event.poll_id || '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        <section className="ak-workspace-tool-card">
          <div className="ak-workspace-tool-head">
            <h3>Attention Score</h3>
          </div>
          <div className="ak-workspace-table-wrap">
            <table className="ak-workspace-table">
              <thead>
                <tr>
                  <th>User</th>
                  <th>Role</th>
                  <th>Checks</th>
                  <th>Focus / Blur</th>
                  <th>Score</th>
                </tr>
              </thead>
              <tbody>
                {!loadingData && !analytics.attention.length && <tr><td colSpan="5">No attention data.</td></tr>}
                {analytics.attention.map((user) => (
                  <tr key={`${user.user_id}-${user.name}`}>
                    <td>{user.name || user.user_id || '-'}</td>
                    <td>{user.role || '-'}</td>
                    <td>{`${user.checks_ok || 0}/${user.checks_total || 0}`}</td>
                    <td>{`${user.focus_count || 0}/${user.blur_count || 0}`}</td>
                    <td>{user.compliance_score || 0}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </div>
  );
}

function AdminWorkspace({ copy, adminCards, language, actorName }) {
  const adminCopy = copy.adminControls;
  const { rooms, loading: roomsLoading, error: roomsError } = useExtRooms();
  const [selectedRoom, setSelectedRoom] = useState('');
  const [recentMeetings, setRecentMeetings] = useState([]);
  const [selectedMeeting, setSelectedMeeting] = useState('');
  const [loadingMeetings, setLoadingMeetings] = useState(false);
  const [roomRules, setRoomRules] = useState({
    enabled: false,
    intervalMinutes: '10',
    jitterSeconds: '30',
    ttlSeconds: '30',
    maxMissedAllowed: '0',
    updatedBy: actorName,
  });
  const [liveControls, setLiveControls] = useState({
    enabled: false,
    intervalMinutes: '10',
    jitterSeconds: '30',
    ttlSeconds: '30',
    updatedBy: actorName,
    issueAttendanceTtl: '25',
    quizPrompt: '',
    quizExpected: '',
    quizTtl: '30',
  });
  const [roomRulesStatus, setRoomRulesStatus] = useState({ message: '', error: false });
  const [liveStatus, setLiveStatus] = useState({ message: '', error: false });
  const [filters, setFilters] = useState({
    action: '',
    targetType: '',
    actor: '',
    targetId: '',
    limit: '100',
  });
  const [auditLogs, setAuditLogs] = useState([]);
  const [loadingAudit, setLoadingAudit] = useState(false);
  const [status, setStatus] = useState({ message: '', error: false });
  const [hasLoadedInitialAudit, setHasLoadedInitialAudit] = useState(false);

  useEffect(() => {
    if (!selectedRoom && rooms.length) {
      setSelectedRoom(rooms[0].id);
    }
  }, [rooms, selectedRoom]);

  useEffect(() => {
    let active = true;

    const loadMeetings = async () => {
      if (!selectedRoom) {
        setRecentMeetings([]);
        setSelectedMeeting('');
        return;
      }

      setLoadingMeetings(true);
      try {
        const params = new URLSearchParams();
        params.set('limit', '100');
        params.set('includeEnded', '1');
        params.set('room', selectedRoom);
        const data = await fetchExtJson(`/ext/recent-meetings?${params.toString()}`);
        if (!active) return;
        const meetings = data.meetings || [];
        setRecentMeetings(meetings);
        setSelectedMeeting((prev) => {
          if (prev && meetings.find((meeting) => meeting.meeting_int_id === prev)) return prev;
          return meetings[0]?.meeting_int_id || '';
        });
      } catch (err) {
        if (!active) return;
        setRecentMeetings([]);
        setSelectedMeeting('');
        setLiveStatus({ message: normalizeExtError(err), error: true });
      } finally {
        if (active) setLoadingMeetings(false);
      }
    };

    loadMeetings();

    return () => {
      active = false;
    };
  }, [selectedRoom]);

  const loadRoomRules = useCallback(async (roomId = selectedRoom, silent = false) => {
    if (!roomId) {
      if (!silent) setRoomRulesStatus({ message: adminCopy.requiredRoom, error: true });
      return;
    }

    try {
      const data = await fetchExtJson(`/ext/room-rules?room=${encodeURIComponent(roomId)}`);
      const rules = data.rules || {};
      setRoomRules((prev) => ({
        ...prev,
        enabled: !!rules.enabled,
        intervalMinutes: String(rules.interval_minutes ?? 10),
        jitterSeconds: String(rules.jitter_seconds ?? 30),
        ttlSeconds: String(rules.ttl_seconds ?? 30),
        maxMissedAllowed: String(rules.max_missed_allowed ?? 0),
        updatedBy: rules.updated_by || prev.updatedBy || actorName,
      }));
      if (!silent) setRoomRulesStatus({ message: adminCopy.roomRulesLoaded, error: false });
    } catch (err) {
      if (!silent) setRoomRulesStatus({ message: adminCopy.roomRulesError, error: true });
    }
  }, [selectedRoom, adminCopy, actorName]);

  useEffect(() => {
    if (selectedRoom) {
      loadRoomRules(selectedRoom, true);
    }
  }, [selectedRoom, loadRoomRules]);

  const saveRoomRules = async () => {
    if (!selectedRoom) {
      setRoomRulesStatus({ message: adminCopy.requiredRoom, error: true });
      return;
    }

    try {
      const data = await fetchExtJson('/ext/room-rules/upsert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          room: selectedRoom,
          enabled: !!roomRules.enabled,
          interval_minutes: Math.min(Math.max(parseInt(roomRules.intervalMinutes, 10) || 10, 1), 180),
          jitter_seconds: Math.min(Math.max(parseInt(roomRules.jitterSeconds, 10) || 30, 0), 1800),
          ttl_seconds: Math.min(Math.max(parseInt(roomRules.ttlSeconds, 10) || 30, 10), 600),
          max_missed_allowed: Math.min(Math.max(parseInt(roomRules.maxMissedAllowed, 10) || 0, 0), 1000),
          updated_by: roomRules.updatedBy.trim() || actorName,
          metadata: { source: 'greenlight-workspace' },
        }),
      });
      const rules = data.rules || {};
      setRoomRules((prev) => ({
        ...prev,
        enabled: !!rules.enabled,
        intervalMinutes: String(rules.interval_minutes ?? prev.intervalMinutes),
        jitterSeconds: String(rules.jitter_seconds ?? prev.jitterSeconds),
        ttlSeconds: String(rules.ttl_seconds ?? prev.ttlSeconds),
        maxMissedAllowed: String(rules.max_missed_allowed ?? prev.maxMissedAllowed),
        updatedBy: rules.updated_by || prev.updatedBy,
      }));
      setRoomRulesStatus({ message: adminCopy.roomRulesSaved, error: false });
    } catch (err) {
      setRoomRulesStatus({ message: adminCopy.roomRulesError, error: true });
    }
  };

  const loadLiveControls = useCallback(async (meetingId = selectedMeeting, silent = false) => {
    if (!meetingId) {
      if (!silent) setLiveStatus({ message: adminCopy.requiredMeeting, error: true });
      return;
    }

    try {
      const data = await fetchExtJson(`/ext/meeting-live-controls?meeting_int_id=${encodeURIComponent(meetingId)}`);
      const controls = data.controls || {};
      setLiveControls((prev) => ({
        ...prev,
        enabled: !!controls.enabled,
        intervalMinutes: String(controls.interval_minutes ?? 10),
        jitterSeconds: String(controls.jitter_seconds ?? 30),
        ttlSeconds: String(controls.ttl_seconds ?? 30),
        updatedBy: controls.updated_by || prev.updatedBy || actorName,
      }));
      if (!silent) setLiveStatus({ message: adminCopy.liveLoaded, error: false });
    } catch (err) {
      if (!silent) setLiveStatus({ message: adminCopy.liveError, error: true });
    }
  }, [selectedMeeting, adminCopy, actorName]);

  useEffect(() => {
    if (selectedMeeting) {
      loadLiveControls(selectedMeeting, true);
    }
  }, [selectedMeeting, loadLiveControls]);

  const saveLiveControls = async () => {
    if (!selectedMeeting) {
      setLiveStatus({ message: adminCopy.requiredMeeting, error: true });
      return;
    }

    try {
      await fetchExtJson('/ext/meeting-live-controls/upsert', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          meeting_int_id: selectedMeeting,
          enabled: !!liveControls.enabled,
          interval_minutes: Math.min(Math.max(parseInt(liveControls.intervalMinutes, 10) || 10, 1), 180),
          jitter_seconds: Math.min(Math.max(parseInt(liveControls.jitterSeconds, 10) || 30, 0), 1800),
          ttl_seconds: Math.min(Math.max(parseInt(liveControls.ttlSeconds, 10) || 30, 10), 600),
          updated_by: liveControls.updatedBy.trim() || actorName,
          metadata: { source: 'greenlight-workspace' },
        }),
      });
      setLiveStatus({ message: adminCopy.liveSaved, error: false });
    } catch (err) {
      setLiveStatus({ message: adminCopy.liveError, error: true });
    }
  };

  const issueAttendanceNow = async () => {
    if (!selectedMeeting) {
      setLiveStatus({ message: adminCopy.requiredMeeting, error: true });
      return;
    }

    try {
      const data = await fetchExtJson('/ext/meeting-live-controls/issue-now', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          meeting_int_id: selectedMeeting,
          ttl_seconds: Math.min(Math.max(parseInt(liveControls.issueAttendanceTtl, 10) || 25, 10), 600),
          updated_by: liveControls.updatedBy.trim() || actorName,
        }),
      });
      setLiveStatus({ message: `${adminCopy.issueDone} (${data.recipients_count || 0})`, error: false });
    } catch (err) {
      setLiveStatus({ message: adminCopy.issueError, error: true });
    }
  };

  const issueQuizNow = async () => {
    if (!selectedMeeting) {
      setLiveStatus({ message: adminCopy.requiredMeeting, error: true });
      return;
    }
    if (!liveControls.quizPrompt.trim() || !liveControls.quizExpected.trim()) {
      setLiveStatus({ message: adminCopy.requiredQuiz, error: true });
      return;
    }

    try {
      const data = await fetchExtJson('/ext/meeting-live-controls/issue-quiz-now', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          meeting_int_id: selectedMeeting,
          prompt: liveControls.quizPrompt.trim(),
          expected_answer: liveControls.quizExpected.trim(),
          ttl_seconds: Math.min(Math.max(parseInt(liveControls.quizTtl, 10) || 30, 10), 600),
          updated_by: liveControls.updatedBy.trim() || actorName,
          metadata: { source: 'greenlight-workspace' },
        }),
      });
      setLiveStatus({ message: `${adminCopy.issueDone} (${data.recipients_count || 0})`, error: false });
    } catch (err) {
      setLiveStatus({ message: adminCopy.issueError, error: true });
    }
  };

  const loadAuditLogs = useCallback(async (overrideFilters = filters) => {
    setLoadingAudit(true);
    try {
      const params = new URLSearchParams();
      params.set('limit', String(Math.min(Math.max(parseInt(overrideFilters.limit, 10) || 100, 1), 2000)));
      if (overrideFilters.action.trim()) params.set('action', overrideFilters.action.trim());
      if (overrideFilters.targetType.trim()) params.set('target_type', overrideFilters.targetType.trim());
      if (overrideFilters.actor.trim()) params.set('actor', overrideFilters.actor.trim());
      if (overrideFilters.targetId.trim()) params.set('target_id', overrideFilters.targetId.trim());

      const data = await fetchExtJson(`/ext/audit-logs?${params.toString()}`);
      const logs = data.logs || [];
      setAuditLogs(logs);
      setStatus({ message: `${logs.length} audit log(s) loaded.`, error: false });
    } catch (err) {
      setAuditLogs([]);
      setStatus({ message: normalizeExtError(err), error: true });
    } finally {
      setLoadingAudit(false);
    }
  }, [filters]);

  useEffect(() => {
    if (!hasLoadedInitialAudit) {
      setHasLoadedInitialAudit(true);
      loadAuditLogs();
    }
  }, [hasLoadedInitialAudit, loadAuditLogs]);

  const setFilter = (key, value) => {
    setFilters((prev) => ({ ...prev, [key]: value }));
  };

  const totalLogs = auditLogs.length;
  const uniqueActors = new Set(auditLogs.map((log) => log.actor).filter(Boolean)).size;
  const exportLogs = auditLogs.filter((log) => (log.action || '').toLowerCase().includes('export')).length;
  const scheduleLogs = auditLogs.filter((log) => {
    const action = (log.action || '').toLowerCase();
    return action.includes('future') || action.includes('schedule');
  }).length;

  const applyPreset = (next) => {
    const merged = { ...filters, ...next };
    setFilters(merged);
    loadAuditLogs(merged);
  };

  return (
    <div className="ak-workspace-panel">
      <PanelIntro eyebrow={copy.tabs.admin} title={copy.adminPanel.title} body={copy.adminPanel.body} />

      <section className="ak-workspace-metrics-grid ak-workspace-metrics-grid-tight">
        <MetricCard accent="slate" icon={DocumentDuplicateIcon} label={copy.adminWidgets.logs} value={totalLogs} helper="audit" />
        <MetricCard accent="blue" icon={IdentificationIcon} label={copy.adminWidgets.actors} value={uniqueActors} helper="unique" />
        <MetricCard accent="red" icon={LinkIcon} label={copy.adminWidgets.exports} value={exportLogs} helper="actions" />
        <MetricCard accent="dark" icon={CalendarDaysIcon} label={copy.adminWidgets.schedule} value={scheduleLogs} helper="actions" />
      </section>

      <div className="ak-workspace-action-grid ak-workspace-action-grid-gap-bottom">
        {adminCards.map((card) => (
          <ActionCard
            key={card.title}
            title={card.title}
            body={card.body}
            icon={card.icon}
            href={card.href}
            accent="admin"
          />
        ))}
      </div>

      <div className="ak-workspace-tool-grid ak-workspace-tool-grid-2 ak-workspace-tool-grid-gap-bottom">
        <section className="ak-workspace-tool-card">
          <div className="ak-workspace-tool-head">
            <h3>{adminCopy.roomRules}</h3>
          </div>

          <div className="ak-workspace-form-grid">
            <label className="ak-workspace-field">
              <span>{adminCopy.room}</span>
              <select className="ak-workspace-select" value={selectedRoom} onChange={(event) => setSelectedRoom(event.target.value)}>
                <option value="">{roomsLoading ? copy.recordingsDetail.loading : adminCopy.selectRoom}</option>
                {rooms.map((room) => <option key={room.id} value={room.id}>{room.label}</option>)}
              </select>
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.updatedBy}</span>
              <input className="ak-workspace-input" value={roomRules.updatedBy} onChange={(event) => setRoomRules((prev) => ({ ...prev, updatedBy: event.target.value }))} />
            </label>

            <label className="ak-workspace-field ak-workspace-toggle">
              <span>{adminCopy.enabled}</span>
              <input type="checkbox" checked={roomRules.enabled} onChange={(event) => setRoomRules((prev) => ({ ...prev, enabled: event.target.checked }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.interval}</span>
              <input type="number" min="1" max="180" className="ak-workspace-input" value={roomRules.intervalMinutes} onChange={(event) => setRoomRules((prev) => ({ ...prev, intervalMinutes: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.jitter}</span>
              <input type="number" min="0" max="1800" className="ak-workspace-input" value={roomRules.jitterSeconds} onChange={(event) => setRoomRules((prev) => ({ ...prev, jitterSeconds: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.ttl}</span>
              <input type="number" min="10" max="600" className="ak-workspace-input" value={roomRules.ttlSeconds} onChange={(event) => setRoomRules((prev) => ({ ...prev, ttlSeconds: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.maxMissed}</span>
              <input type="number" min="0" max="1000" className="ak-workspace-input" value={roomRules.maxMissedAllowed} onChange={(event) => setRoomRules((prev) => ({ ...prev, maxMissedAllowed: event.target.value }))} />
            </label>

            <div className="ak-workspace-inline-actions ak-workspace-field-span-2">
              <button type="button" className="ak-workspace-link-btn" onClick={() => loadRoomRules(selectedRoom)}>{adminCopy.load}</button>
              <button type="button" className="ak-workspace-primary-btn" onClick={saveRoomRules}>{adminCopy.save}</button>
            </div>
          </div>

          {(roomsError || roomRulesStatus.message) && (
            <p className={`ak-workspace-status ${roomRulesStatus.error || roomsError ? 'is-error' : ''}`}>
              {roomsError || roomRulesStatus.message}
            </p>
          )}
        </section>

        <section className="ak-workspace-tool-card">
          <div className="ak-workspace-tool-head">
            <h3>{adminCopy.liveControls}</h3>
          </div>

          <div className="ak-workspace-form-grid">
            <label className="ak-workspace-field ak-workspace-field-span-2">
              <span>{adminCopy.meeting}</span>
              <select className="ak-workspace-select" value={selectedMeeting} onChange={(event) => setSelectedMeeting(event.target.value)}>
                <option value="">{loadingMeetings ? copy.recordingsDetail.loading : adminCopy.selectMeeting}</option>
                {recentMeetings.map((meeting) => (
                  <option key={meeting.meeting_int_id} value={meeting.meeting_int_id}>
                    {meeting.meeting_name || meeting.meeting_int_id}
                  </option>
                ))}
              </select>
            </label>

            <label className="ak-workspace-field ak-workspace-toggle">
              <span>{adminCopy.enabled}</span>
              <input type="checkbox" checked={liveControls.enabled} onChange={(event) => setLiveControls((prev) => ({ ...prev, enabled: event.target.checked }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.updatedBy}</span>
              <input className="ak-workspace-input" value={liveControls.updatedBy} onChange={(event) => setLiveControls((prev) => ({ ...prev, updatedBy: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.interval}</span>
              <input type="number" min="1" max="180" className="ak-workspace-input" value={liveControls.intervalMinutes} onChange={(event) => setLiveControls((prev) => ({ ...prev, intervalMinutes: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.jitter}</span>
              <input type="number" min="0" max="1800" className="ak-workspace-input" value={liveControls.jitterSeconds} onChange={(event) => setLiveControls((prev) => ({ ...prev, jitterSeconds: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.ttl}</span>
              <input type="number" min="10" max="600" className="ak-workspace-input" value={liveControls.ttlSeconds} onChange={(event) => setLiveControls((prev) => ({ ...prev, ttlSeconds: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.attendanceTtl}</span>
              <input type="number" min="10" max="600" className="ak-workspace-input" value={liveControls.issueAttendanceTtl} onChange={(event) => setLiveControls((prev) => ({ ...prev, issueAttendanceTtl: event.target.value }))} />
            </label>

            <label className="ak-workspace-field ak-workspace-field-span-2">
              <span>{adminCopy.quizPrompt}</span>
              <input className="ak-workspace-input" value={liveControls.quizPrompt} onChange={(event) => setLiveControls((prev) => ({ ...prev, quizPrompt: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.quizExpected}</span>
              <input className="ak-workspace-input" value={liveControls.quizExpected} onChange={(event) => setLiveControls((prev) => ({ ...prev, quizExpected: event.target.value }))} />
            </label>

            <label className="ak-workspace-field">
              <span>{adminCopy.quizTtl}</span>
              <input type="number" min="10" max="600" className="ak-workspace-input" value={liveControls.quizTtl} onChange={(event) => setLiveControls((prev) => ({ ...prev, quizTtl: event.target.value }))} />
            </label>

            <div className="ak-workspace-inline-actions ak-workspace-field-span-2">
              <button type="button" className="ak-workspace-link-btn" onClick={() => loadLiveControls(selectedMeeting)}>{adminCopy.load}</button>
              <button type="button" className="ak-workspace-primary-btn" onClick={saveLiveControls}>{adminCopy.save}</button>
              <button type="button" className="ak-workspace-link-btn" onClick={issueAttendanceNow}>{adminCopy.issueAttendance}</button>
              <button type="button" className="ak-workspace-link-btn" onClick={issueQuizNow}>{adminCopy.issueQuiz}</button>
            </div>
          </div>

          {liveStatus.message && (
            <p className={`ak-workspace-status ${liveStatus.error ? 'is-error' : ''}`}>
              {liveStatus.message}
            </p>
          )}
        </section>
      </div>

      <section className="ak-workspace-tool-card">
        <div className="ak-workspace-tool-head">
          <h3>Audit Logs</h3>
        </div>

        <div className="ak-workspace-inline-actions ak-workspace-inline-actions-top ak-workspace-inline-actions-wrap">
          <span className="ak-workspace-mini-label">{copy.adminWidgets.presets}</span>
          <button type="button" className="ak-workspace-link-btn" onClick={() => applyPreset({ action: 'export', targetType: '' })}>{copy.adminWidgets.presetExport}</button>
          <button type="button" className="ak-workspace-link-btn" onClick={() => applyPreset({ action: 'future', targetType: '' })}>{copy.adminWidgets.presetSchedule}</button>
          <button type="button" className="ak-workspace-link-btn" onClick={() => applyPreset({ action: 'attendance', targetType: '' })}>{copy.adminWidgets.presetAttendance}</button>
          <button type="button" className="ak-workspace-link-btn" onClick={() => applyPreset({ action: '', targetType: 'admin' })}>{copy.adminWidgets.presetAdmin}</button>
        </div>

        <div className="ak-workspace-form-grid ak-workspace-form-grid-audit">
          <label className="ak-workspace-field">
            <span>Action</span>
            <input className="ak-workspace-input" value={filters.action} onChange={(event) => setFilter('action', event.target.value)} />
          </label>
          <label className="ak-workspace-field">
            <span>Target Type</span>
            <input className="ak-workspace-input" value={filters.targetType} onChange={(event) => setFilter('targetType', event.target.value)} />
          </label>
          <label className="ak-workspace-field">
            <span>Actor</span>
            <input className="ak-workspace-input" value={filters.actor} onChange={(event) => setFilter('actor', event.target.value)} />
          </label>
          <label className="ak-workspace-field">
            <span>Target ID</span>
            <input className="ak-workspace-input" value={filters.targetId} onChange={(event) => setFilter('targetId', event.target.value)} />
          </label>
          <label className="ak-workspace-field">
            <span>Limit</span>
            <input type="number" min="1" max="2000" className="ak-workspace-input" value={filters.limit} onChange={(event) => setFilter('limit', event.target.value)} />
          </label>
          <div className="ak-workspace-inline-actions">
            <button type="button" className="ak-workspace-primary-btn" onClick={loadAuditLogs}>Load Logs</button>
          </div>
        </div>

        {(status.message || loadingAudit) && (
          <p className={`ak-workspace-status ${status.error ? 'is-error' : ''}`}>
            {loadingAudit ? 'Loading audit logs...' : status.message}
          </p>
        )}

        <div className="ak-workspace-table-wrap">
          <table className="ak-workspace-table">
            <thead>
              <tr>
                <th>Time</th>
                <th>Actor</th>
                <th>Action</th>
                <th>Target</th>
                <th>IP</th>
                <th>Payload</th>
              </tr>
            </thead>
            <tbody>
              {!loadingAudit && !auditLogs.length && <tr><td colSpan="6">No audit logs found.</td></tr>}
              {auditLogs.map((log) => (
                <tr key={`${log.created_at}-${log.action}-${log.target_id}`}>
                  <td>{formatDateTime(log.created_at, language)}</td>
                  <td>{log.actor || '-'}</td>
                  <td>{log.action || '-'}</td>
                  <td>{`${log.target_type || ''}${log.target_type || log.target_id ? ':' : ''}${log.target_id || ''}` || '-'}</td>
                  <td>{log.ip_addr || '-'}</td>
                  <td><code className="ak-workspace-code">{JSON.stringify(log.payload || {})}</code></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

function PanelIntro({ eyebrow, title, body }) {
  return (
    <div className="ak-workspace-panel-intro">
      {eyebrow && <span className="ak-workspace-panel-eyebrow">{eyebrow}</span>}
      <h2>{title}</h2>
      {body && <p>{body}</p>}
    </div>
  );
}

function OverviewVisuals({
  copy,
  totalRooms,
  liveRooms,
  sharedRooms,
  accessCount,
  canViewRecordings,
  roomsLoading,
}) {
  const safeTotal = Math.max(totalRooms, 1);
  const idleRooms = Math.max(totalRooms - liveRooms, 0);
  const livePct = totalRooms ? Math.round((liveRooms / safeTotal) * 100) : 0;
  const idlePct = totalRooms ? Math.round((idleRooms / safeTotal) * 100) : 0;
  const sharedPct = totalRooms ? Math.round((sharedRooms / safeTotal) * 100) : 0;

  const barRows = [
    { key: 'live', label: copy.visuals.live, count: liveRooms, percent: livePct, accent: 'red' },
    { key: 'idle', label: copy.visuals.idle, count: idleRooms, percent: idlePct, accent: 'blue' },
    { key: 'shared', label: copy.visuals.shared, count: sharedRooms, percent: sharedPct, accent: 'slate' },
  ];

  return (
    <section className="ak-workspace-visual-grid">
      <div className="ak-workspace-visual-card">
        <div className="ak-workspace-visual-head">
          <span>{copy.visuals.title}</span>
          <strong>{roomsLoading ? '...' : totalRooms}</strong>
        </div>

        <div className="ak-workspace-visual-ring-wrap">
          <div
            className="ak-workspace-visual-ring"
            style={{ '--ak-ring-fill': `${livePct}%` }}
          >
            <div className="ak-workspace-visual-ring-core">
              <strong>{roomsLoading ? '...' : `${livePct}%`}</strong>
              <span>{copy.visuals.occupancy}</span>
            </div>
          </div>
        </div>

        <div className="ak-workspace-visual-meta">
          <div className="ak-workspace-visual-pill">
            <span>{copy.visuals.access}</span>
            <strong>{accessCount}/6</strong>
          </div>
          <div className="ak-workspace-visual-pill">
            <span>{canViewRecordings ? copy.visuals.recordingsOn : copy.visuals.recordingsOff}</span>
            <strong>{canViewRecordings ? copy.visuals.stateOn : copy.visuals.stateOff}</strong>
          </div>
        </div>
      </div>

      <div className="ak-workspace-visual-card">
        <div className="ak-workspace-visual-head">
          <span>{copy.visuals.breakdown}</span>
        </div>

        <div className="ak-workspace-bar-list">
          {barRows.map((item) => (
            <div key={item.key} className="ak-workspace-bar-row">
              <div className="ak-workspace-bar-label">
                <span>{item.label}</span>
                <strong>{roomsLoading ? '...' : item.count}</strong>
              </div>
              <div className="ak-workspace-bar-track">
                <span
                  className={`ak-workspace-bar-fill is-${item.accent}`}
                  style={{ width: `${item.percent}%` }}
                />
              </div>
              <span className="ak-workspace-bar-percent">{roomsLoading ? '...' : `${item.percent}%`}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function OverviewInsights({ copy, language }) {
  const { rooms, loading: roomsLoading, error: roomsError } = useExtRooms();
  const [recentMeetings, setRecentMeetings] = useState([]);
  const [loadingMeetings, setLoadingMeetings] = useState(true);

  useEffect(() => {
    let active = true;

    const loadMeetings = async () => {
      setLoadingMeetings(true);
      try {
        const data = await fetchExtJson('/ext/recent-meetings?limit=8&includeEnded=1');
        if (!active) return;
        setRecentMeetings((data.meetings || []).slice(0, 8).reverse());
      } catch (_) {
        if (!active) return;
        setRecentMeetings([]);
      } finally {
        if (active) setLoadingMeetings(false);
      }
    };

    loadMeetings();

    return () => {
      active = false;
    };
  }, []);

  const topRooms = [...rooms]
    .sort((a, b) => (b.sessionsCount || 0) - (a.sessionsCount || 0))
    .slice(0, 5);

  const maxMeetingUsers = recentMeetings.reduce((max, meeting) => Math.max(max, meeting.participants_count || 0), 1);
  const maxRoomSessions = topRooms.reduce((max, room) => Math.max(max, room.sessionsCount || 0), 1);

  return (
    <section className="ak-workspace-tool-grid ak-workspace-tool-grid-2 ak-workspace-tool-grid-gap-bottom">
      <section className="ak-workspace-tool-card">
        <div className="ak-workspace-tool-head">
          <h3>{copy.insights.trend}</h3>
        </div>

        {loadingMeetings && <p className="ak-workspace-status">Loading...</p>}
        {!loadingMeetings && !recentMeetings.length && <p className="ak-workspace-status">{copy.insights.noTrend}</p>}

        {!loadingMeetings && recentMeetings.length > 0 && (
          <div className="ak-workspace-trend-chart">
            {recentMeetings.map((meeting) => {
              const users = meeting.participants_count || 0;
              const height = `${Math.max(Math.round((users / maxMeetingUsers) * 100), users ? 18 : 8)}%`;
              return (
                <div key={`${meeting.meeting_int_id || meeting.created_at}`} className="ak-workspace-trend-bar-col">
                  <span className="ak-workspace-trend-bar-value">{users}</span>
                  <div className="ak-workspace-trend-bar-track">
                    <span className="ak-workspace-trend-bar-fill" style={{ height }} />
                  </div>
                  <span className="ak-workspace-trend-bar-label">{formatShortDate(meeting.created_at, language)}</span>
                </div>
              );
            })}
          </div>
        )}
      </section>

      <section className="ak-workspace-tool-card">
        <div className="ak-workspace-tool-head">
          <h3>{copy.insights.topRooms}</h3>
        </div>

        {roomsLoading && <p className="ak-workspace-status">Loading...</p>}
        {!roomsLoading && !topRooms.length && <p className={`ak-workspace-status ${roomsError ? 'is-error' : ''}`}>{roomsError || copy.insights.noRooms}</p>}

        {!roomsLoading && topRooms.length > 0 && (
          <div className="ak-workspace-ranked-list">
            {topRooms.map((room) => (
              <div key={room.id} className="ak-workspace-ranked-row">
                <div className="ak-workspace-ranked-copy">
                  <strong>{room.id}</strong>
                  <span>{room.sessionsCount || 0} {copy.insights.sessions}</span>
                </div>
                <div className="ak-workspace-ranked-track">
                  <span
                    className="ak-workspace-ranked-fill"
                    style={{ width: `${Math.max(Math.round(((room.sessionsCount || 0) / maxRoomSessions) * 100), room.sessionsCount ? 10 : 0)}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        )}
      </section>
    </section>
  );
}

function RecordingsWorkspace({ copy, language }) {
  const { rooms, loading: roomsLoading, error: roomsError } = useExtRooms();
  const [selectedRoom, setSelectedRoom] = useState('');
  const [pastMeetings, setPastMeetings] = useState([]);
  const [selectedMeeting, setSelectedMeeting] = useState('');
  const [pastUsers, setPastUsers] = useState([]);
  const [loadingMeetings, setLoadingMeetings] = useState(false);
  const [loadingUsers, setLoadingUsers] = useState(false);
  const [status, setStatus] = useState({ message: '', error: false });

  useEffect(() => {
    if (!selectedRoom && rooms.length) {
      setSelectedRoom(rooms[0].id);
    }
  }, [rooms, selectedRoom]);

  useEffect(() => {
    let active = true;

    const loadPastMeetings = async () => {
      if (!selectedRoom) {
        setPastMeetings([]);
        setSelectedMeeting('');
        return;
      }

      setLoadingMeetings(true);
      try {
        const data = await fetchExtJson(`/ext/past-meetings?room=${encodeURIComponent(selectedRoom)}&limit=20&includeRecordings=1`);
        if (!active) return;
        const meetings = data.meetings || [];
        setPastMeetings(meetings);
        setSelectedMeeting((prev) => {
          if (prev && meetings.find((meeting) => meeting.meeting_int_id === prev)) return prev;
          return meetings[0]?.meeting_int_id || '';
        });
        setStatus({ message: '', error: false });
      } catch (err) {
        if (!active) return;
        setPastMeetings([]);
        setSelectedMeeting('');
        setStatus({ message: normalizeExtError(err), error: true });
      } finally {
        if (active) setLoadingMeetings(false);
      }
    };

    loadPastMeetings();

    return () => {
      active = false;
    };
  }, [selectedRoom]);

  useEffect(() => {
    let active = true;

    const loadPastUsers = async () => {
      if (!selectedMeeting) {
        setPastUsers([]);
        return;
      }

      setLoadingUsers(true);
      try {
        const data = await fetchExtJson(`/ext/past-meeting-users?meeting_int_id=${encodeURIComponent(selectedMeeting)}`);
        if (!active) return;
        setPastUsers(data.users || []);
      } catch (err) {
        if (!active) return;
        setPastUsers([]);
        setStatus({ message: normalizeExtError(err), error: true });
      } finally {
        if (active) setLoadingUsers(false);
      }
    };

    loadPastUsers();

    return () => {
      active = false;
    };
  }, [selectedMeeting]);

  const selectedMeetingData = pastMeetings.find((meeting) => meeting.meeting_int_id === selectedMeeting) || null;
  const exportCsvHref = selectedMeeting ? `/ext/export/attendance.csv?meeting_int_id=${encodeURIComponent(selectedMeeting)}&includeChecks=1` : '';
  const exportJsonHref = selectedMeeting ? `/ext/export/attendance.json?meeting_int_id=${encodeURIComponent(selectedMeeting)}&includeChecks=1` : '';
  const recordingHref = selectedMeetingData?.recording?.playback?.url || '';

  return (
    <div className="ak-workspace-panel ak-workspace-recordings">
      <PanelIntro eyebrow={copy.tabs.recordings} title={copy.recordingsPanel.title} body={copy.recordingsPanel.body} />
      <UserRecordings topSpacingClass="pt-0" />

      <section className="ak-workspace-surface ak-workspace-surface-gap-top">
        <div className="ak-workspace-surface-head">
          <h2>{copy.recordingsDetail.title}</h2>
        </div>

        <div className="ak-workspace-tool-grid ak-workspace-tool-grid-2">
          <section className="ak-workspace-tool-card">
            <div className="ak-workspace-tool-head">
              <h3>{copy.recordingsDetail.meetings}</h3>
            </div>

            <div className="ak-workspace-form-grid ak-workspace-form-grid-recordings">
              <label className="ak-workspace-field">
                <span>{copy.recordingsDetail.room}</span>
                <select className="ak-workspace-select" value={selectedRoom} onChange={(event) => setSelectedRoom(event.target.value)}>
                  <option value="">{roomsLoading ? copy.recordingsDetail.loading : copy.recordingsDetail.selectRoom}</option>
                  {rooms.map((room) => <option key={room.id} value={room.id}>{room.label}</option>)}
                </select>
              </label>
            </div>

            {(roomsError || status.message) && (
              <p className={`ak-workspace-status ${status.error || roomsError ? 'is-error' : ''}`}>
                {roomsError || status.message}
              </p>
            )}

            <div className="ak-workspace-table-wrap">
              <table className="ak-workspace-table">
                <thead>
                  <tr>
                    <th>{copy.recordingsDetail.date}</th>
                    <th>{copy.recordingsDetail.meeting}</th>
                    <th>{copy.recordingsDetail.usersCount}</th>
                    <th>{copy.recordingsDetail.duration}</th>
                    <th>{copy.recordingsDetail.attendance}</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {loadingMeetings && <tr><td colSpan="6">{copy.recordingsDetail.loading}</td></tr>}
                  {!loadingMeetings && !pastMeetings.length && <tr><td colSpan="6">{copy.recordingsDetail.noMeetings}</td></tr>}
                  {!loadingMeetings && pastMeetings.map((meeting) => (
                    <tr key={meeting.meeting_int_id}>
                      <td>{formatShortDate(meeting.created_at, language)}</td>
                      <td>{meeting.meeting_name || meeting.meeting_int_id || '-'}</td>
                      <td>{meeting.participants_count || 0}</td>
                      <td>{formatDuration(meeting.duration_seconds, language)}</td>
                      <td>
                        <div className="ak-workspace-badge-row">
                          <span className="ak-workspace-badge is-ok">{copy.recordingsDetail.ok} {meeting.attendance?.checks_ok || 0}</span>
                          <span className="ak-workspace-badge is-warn">{copy.recordingsDetail.late} {meeting.attendance?.checks_late || 0}</span>
                          <span className="ak-workspace-badge is-bad">{copy.recordingsDetail.missed} {meeting.attendance?.checks_missed || 0}</span>
                        </div>
                      </td>
                      <td>
                        <button type="button" className="ak-workspace-row-btn" onClick={() => setSelectedMeeting(meeting.meeting_int_id)}>
                          {copy.recordingsDetail.details}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>

          <section className="ak-workspace-tool-card">
            <div className="ak-workspace-tool-head">
              <h3>{copy.recordingsDetail.users}</h3>
            </div>

            <div className="ak-workspace-inline-actions ak-workspace-inline-actions-top">
              {recordingHref && <a href={recordingHref} target="_blank" rel="noreferrer" className="ak-workspace-link-btn">{copy.recordingsDetail.open}</a>}
              {exportCsvHref && <a href={exportCsvHref} target="_blank" rel="noreferrer" className="ak-workspace-link-btn">{copy.recordingsDetail.exportCsv}</a>}
              {exportJsonHref && <a href={exportJsonHref} target="_blank" rel="noreferrer" className="ak-workspace-link-btn">{copy.recordingsDetail.exportJson}</a>}
            </div>

            <div className="ak-workspace-table-wrap">
              <table className="ak-workspace-table">
                <thead>
                  <tr>
                    <th>{copy.recordingsDetail.user}</th>
                    <th>{copy.recordingsDetail.role}</th>
                    <th>{copy.recordingsDetail.checks}</th>
                    <th>{copy.recordingsDetail.ok}</th>
                    <th>{copy.recordingsDetail.late}</th>
                    <th>{copy.recordingsDetail.missed}</th>
                  </tr>
                </thead>
                <tbody>
                  {loadingUsers && <tr><td colSpan="6">{copy.recordingsDetail.loading}</td></tr>}
                  {!loadingUsers && !selectedMeeting && <tr><td colSpan="6">{copy.recordingsDetail.noUsers}</td></tr>}
                  {!loadingUsers && selectedMeeting && !pastUsers.length && <tr><td colSpan="6">{copy.recordingsDetail.noUsers}</td></tr>}
                  {!loadingUsers && pastUsers.map((user) => (
                    <tr key={`${selectedMeeting}-${user.user_id || user.name}`}>
                      <td>{user.name || user.user_id || '-'}</td>
                      <td>{user.role || '-'}</td>
                      <td>{user.checks_total || 0}</td>
                      <td>{user.checks_ok || 0}</td>
                      <td>{user.checks_late || 0}</td>
                      <td>{user.checks_missed || 0}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>
        </div>
      </section>
    </div>
  );
}

export default function Rooms({ forcedView = null, hideTabs = false }) {
  const currentUser = useAuth();
  const { i18n } = useTranslation();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const { data: recordingsCount } = useRecordingsCount();
  const { data: recordValue } = useRoomConfigValue('record');
  const { data: rooms = [], isLoading: roomsLoading } = useRooms('');

  const language = (i18n.resolvedLanguage || i18n.language || 'en').toLowerCase().startsWith('tr') ? 'tr' : 'en';
  const copy = WORKSPACE_COPY[language];

  const isAdmin = currentUser?.isSuperAdmin || PermissionChecker.isAdmin(currentUser);
  const canCreateRoom = PermissionChecker.hasCreateRoom(currentUser);
  const canViewRecordings = recordValue !== 'false';
  const canManageRooms = PermissionChecker.hasManageRooms(currentUser);
  const canManageUsers = PermissionChecker.hasManageUsers(currentUser);
  const canManageSettings = PermissionChecker.hasManageSiteSettings(currentUser) || PermissionChecker.hasManageRoles(currentUser);
  const hasSharedList = PermissionChecker.hasSharedList(currentUser);

  const persona = isAdmin ? 'admin' : canCreateRoom ? 'instructor' : 'user';
  const roomTabLabel = persona === 'user' ? copy.tabs.courses : copy.tabs.rooms;
  const activeView = forcedView || searchParams.get('view') || 'rooms';

  const workspaceTabs = useMemo(() => {
    const tabs = [
      { key: 'overview', label: copy.tabs.overview, icon: HomeIcon },
      { key: 'rooms', label: roomTabLabel, icon: Square2StackIcon },
    ];

    if (canViewRecordings) {
      tabs.push({ key: 'recordings', label: copy.tabs.recordings, icon: VideoCameraIcon });
    }

    tabs.push(
      { key: 'schedule', label: copy.tabs.schedule, icon: CalendarDaysIcon },
      { key: 'analytics', label: copy.tabs.analytics, icon: ChartBarIcon },
    );

    if (isAdmin) {
      tabs.push({ key: 'admin', label: copy.tabs.admin, icon: AdjustmentsHorizontalIcon });
    }

    return tabs;
  }, [copy.tabs, roomTabLabel, canViewRecordings, isAdmin]);

  useEffect(() => {
    if (forcedView) return;

    if (!workspaceTabs.find((tab) => tab.key === activeView)) {
      const nextParams = new URLSearchParams(searchParams);
      nextParams.delete('view');
      setSearchParams(nextParams, { replace: true });
    }
  }, [activeView, forcedView, searchParams, setSearchParams, workspaceTabs]);

  const setActiveView = (view) => {
    if (forcedView) {
      const routeMap = {
        overview: '/home',
        rooms: '/rooms',
        recordings: '/recordings',
        schedule: '/sessions',
        analytics: '/engagement',
        admin: '/admin',
      };
      navigate(routeMap[view] || '/rooms');
      return;
    }

    const nextParams = new URLSearchParams(searchParams);

    if (view === 'overview') {
      nextParams.delete('view');
    } else {
      nextParams.set('view', view);
    }

    setSearchParams(nextParams);
  };

  const totalRooms = rooms.length;
  const liveRooms = rooms.filter((room) => room.online).length;
  const sharedRooms = rooms.filter((room) => room.shared_owner).length;
  const metricValue = (value) => (roomsLoading && value === 0 ? '...' : value);
  const recordingsMetricValue = !canViewRecordings ? '-' : (recordingsCount ?? '...');

  const accessChips = [
    canCreateRoom && copy.access.create,
    canViewRecordings && copy.access.recordings,
    canManageRooms && copy.access.manageRooms,
    canManageUsers && copy.access.manageUsers,
    canManageSettings && copy.access.manageSettings,
    hasSharedList && copy.access.shared,
  ].filter(Boolean);

  const adminCards = copy.adminPanel.cards.map((card, index) => ({
    ...card,
    icon: [AdjustmentsHorizontalIcon, Square2StackIcon, VideoCameraIcon, IdentificationIcon][index] || AdjustmentsHorizontalIcon,
  }));

  const renderPanel = () => {
    switch (activeView) {
      case 'rooms':
        return (
          <div className="ak-workspace-panel ak-workspace-rooms">
            <PanelIntro eyebrow={roomTabLabel} title={copy.roomsPanel.title} body={copy.roomsPanel.body} />
            <RoomsList topSpacingClass="pt-0" />
          </div>
        );
      case 'recordings':
        return (
          <RecordingsWorkspace copy={copy} language={language} />
        );
      case 'schedule':
        return (
          <ScheduleWorkspace copy={copy} language={language} actorName={currentUser?.name || 'ops-admin'} />
        );
      case 'analytics':
        return (
          <AnalyticsWorkspace copy={copy} language={language} />
        );
      case 'admin':
        return (
          <AdminWorkspace copy={copy} adminCards={adminCards} language={language} actorName={currentUser?.name || 'ops-admin'} />
        );
      case 'overview':
      default:
        return (
          <div className="ak-workspace-panel ak-workspace-overview">
            <section className="ak-workspace-hero">
              <div className="ak-workspace-hero-copy">
                <span className="ak-workspace-hero-eyebrow">{copy.workspace.eyebrow}</span>
                <h1>{copy.workspace.title}</h1>
                <p>{copy.workspace.body}</p>
              </div>
              <div className="ak-workspace-hero-side">
                <span className="ak-workspace-role">{copy.persona[persona]}</span>
                {accessChips.length > 0 && (
                  <div className="ak-workspace-access-chips">
                    {accessChips.map((item) => (
                      <span key={item} className="ak-workspace-access-chip">{item}</span>
                    ))}
                  </div>
                )}
              </div>
            </section>

            <section className="ak-workspace-metrics-grid">
              <MetricCard
                accent="red"
                icon={Square2StackIcon}
                label={copy.metrics.totalRooms}
                value={metricValue(totalRooms)}
                helper={roomTabLabel}
              />
              <MetricCard
                accent="blue"
                icon={ClockIcon}
                label={copy.metrics.liveNow}
                value={metricValue(liveRooms)}
                helper={copy.shortcuts.rooms}
              />
              <MetricCard
                accent="dark"
                icon={VideoCameraIcon}
                label={copy.metrics.recordings}
                value={recordingsMetricValue}
                helper={canViewRecordings ? copy.shortcuts.recordings : copy.workspace.roleScope}
              />
              <MetricCard
                accent="slate"
                icon={LinkIcon}
                label={copy.metrics.shared}
                value={metricValue(sharedRooms)}
                helper={copy.workspace.roleScope}
              />
            </section>

            <OverviewVisuals
              copy={copy}
              totalRooms={totalRooms}
              liveRooms={liveRooms}
              sharedRooms={sharedRooms}
              accessCount={accessChips.length}
              canViewRecordings={canViewRecordings}
              roomsLoading={roomsLoading}
            />

            <OverviewInsights copy={copy} language={language} />

            <section className="ak-workspace-surface">
              <div className="ak-workspace-surface-head">
                <h2>{copy.workspace.quickActions}</h2>
                {copy.workspace.phaseNote && <span>{copy.workspace.phaseNote}</span>}
              </div>
              <div className="ak-workspace-action-grid">
                <ActionCard
                  title={copy.shortcuts.rooms}
                  icon={Square2StackIcon}
                  accent="default"
                  onClick={() => setActiveView('rooms')}
                />
                {canViewRecordings && (
                  <ActionCard
                    title={copy.shortcuts.recordings}
                    icon={VideoCameraIcon}
                    accent="analytics"
                    onClick={() => setActiveView('recordings')}
                  />
                )}
                <ActionCard
                  title={copy.shortcuts.schedule}
                  icon={CalendarDaysIcon}
                  accent="schedule"
                  onClick={() => setActiveView('schedule')}
                />
                <ActionCard
                  title={copy.shortcuts.analytics}
                  icon={ChartBarIcon}
                  accent="analytics"
                  onClick={() => setActiveView('analytics')}
                />
                {isAdmin && (
                  <ActionCard
                    title={copy.shortcuts.admin}
                    icon={AdjustmentsHorizontalIcon}
                    accent="admin"
                    onClick={() => setActiveView('admin')}
                  />
                )}
              </div>
            </section>
          </div>
        );
    }
  };

  return (
    <div className="ak-workspace">
      <div className="ak-workspace-shell">
        {!hideTabs && (
          <div className="ak-workspace-tabs" role="tablist" aria-label="Workspace Sections">
            {workspaceTabs.map((tab) => (
              <WorkspaceTab
                key={tab.key}
                active={activeView === tab.key}
                icon={tab.icon}
                label={tab.label}
                onClick={() => setActiveView(tab.key)}
              />
            ))}
          </div>
        )}
        {renderPanel()}
      </div>
    </div>
  );
}
