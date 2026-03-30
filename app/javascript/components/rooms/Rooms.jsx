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
  ClipboardDocumentListIcon,
  Cog6ToothIcon,
  ClockIcon,
  DocumentDuplicateIcon,
  EnvelopeIcon,
  HomeIcon,
  IdentificationIcon,
  LinkIcon,
  ShieldCheckIcon,
  Square2StackIcon,
  UserGroupIcon,
  UserPlusIcon,
  VideoCameraIcon,
} from '@heroicons/react/24/outline';
import {
  Card,
  Modal as BootstrapModal,
  Tab,
  Tabs,
} from 'react-bootstrap';
import { useTranslation } from 'react-i18next';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../../contexts/auth/AuthProvider';
import axios from '../../helpers/Axios';
import PermissionChecker from '../../helpers/PermissionChecker';
import useEnv from '../../hooks/queries/env/useEnv';
import useRoles from '../../hooks/queries/admin/roles/useRoles';
import useRecordings from '../../hooks/queries/recordings/useRecordings';
import useRecordingsCount from '../../hooks/queries/recordings/useRecordingsCount';
import useServerRooms from '../../hooks/queries/admin/server_rooms/useServerRooms';
import useSiteSetting from '../../hooks/queries/site_settings/useSiteSetting';
import useRoomConfigValue from '../../hooks/queries/rooms/useRoomConfigValue';
import useRooms from '../../hooks/queries/rooms/useRooms';
import BannedUsers from '../admin/manage_users/BannedUsers';
import InvitedUsersTable from '../admin/manage_users/InvitedUsersTable';
import PendingUsers from '../admin/manage_users/PendingUsers';
import UnverifiedUsers from '../admin/manage_users/UnverifiedUsers';
import VerifiedUsers from '../admin/manage_users/VerifiedUsers';
import InviteUserForm from '../admin/manage_users/forms/InviteUserForm';
import UserSignupForm from '../admin/manage_users/forms/UserSignupForm';
import RolesList from '../admin/roles/RolesList';
import ServerRoomRow from '../admin/server_rooms/ServerRoomRow';
import ServerRoomsRowPlaceHolder from '../admin/server_rooms/ServerRoomsRowPlaceHolder';
import Administration from '../admin/site_settings/administration/Administration';
import Appearance from '../admin/site_settings/appearance/Appearance';
import Registration from '../admin/site_settings/registration/Registration';
import Settings from '../admin/site_settings/settings/Settings';
import CreateRoleModal from '../shared_components/modals/CreateRoleModal';
import InlineModal from '../shared_components/modals/Modal';
import Pagination from '../shared_components/Pagination';
import NoSearchResults from '../shared_components/search/NoSearchResults';
import SearchBar from '../shared_components/search/SearchBar';
import SortBy from '../shared_components/search/SortBy';
import RoomsList from './RoomsList';
import EmptyServerRoomsList from './EmptyServerRoomsList';

const WORKSPACE_COPY = {
  en: {
    tabs: {
      overview: 'Overview',
      rooms: 'Rooms',
      courses: 'Courses',
      recordings: 'Recordings',
      schedule: 'Sessions',
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
      participants: 'participants',
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
      rooms: 'Server Rooms',
      sections: 'Admin Areas',
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
      overviewTitle: 'Admin Overview',
      manageUsersTab: 'Manage Users',
      serverRoomsTab: 'Server Rooms',
      roomConfigTab: 'Room Configuration',
      siteSettingsTab: 'Site Settings',
      rolesTab: 'Manage Roles',
      auditLogsTab: 'Audit Logs',
      manageUsersBody: 'Open the dedicated user management screen for verification, roles, and access.',
      serverRoomsBody: 'Review and maintain the complete server room inventory.',
      roomConfigBody: 'Configure room rules and live controls without leaving this workspace.',
      siteSettingsBody: 'Customize Greenlight branding, registration, and platform behavior.',
      rolesBody: 'Manage custom roles and permission sets.',
      openSection: 'Open section',
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
      title: 'All Recordings',
      body: 'Search, filter, and review recordings across all rooms.',
      filtersTitle: 'Recording board',
      room: 'Room',
      allRooms: 'All rooms',
      visibility: 'Visibility',
      allVisibility: 'All visibility',
      search: 'Search',
      searchPlaceholder: 'Search recording name or session ID',
      resetFilters: 'Reset filters',
      tableTitle: 'All Recordings',
      tableBody: 'Recordings from every room and session you can access.',
      recordingCol: 'Recording',
      roomCol: 'Room',
      recordedCol: 'Recorded',
      durationCol: 'Duration',
      participantsCol: 'Participants',
      visibilityCol: 'Visibility',
      formatsCol: 'Formats',
      actionsCol: 'Options',
      open: 'Watch',
      statsTotal: 'Total recordings',
      statsFiltered: 'Filtered results',
      statsFormats: 'Available formats',
      statsParticipants: 'Participants on page',
      loading: 'Loading recordings...',
      noMatches: 'No recordings match the current filters.',
    },
    schedulePanel: {
      title: 'All Sessions',
      body: 'Review and manage sessions across rooms.',
      filtersTitle: 'Session board',
      filtersBody: '',
      room: 'Room',
      allRooms: 'All rooms',
      selectRoom: 'Select room',
      loadingRooms: 'Loading rooms...',
      statusFilter: 'Status',
      allStatuses: 'All statuses',
      search: 'Search',
      searchPlaceholder: 'Search title, description, creator',
      resetFilters: 'Reset filters',
      reload: 'Reload',
      openPlanner: 'Open planner',
      closePlanner: 'Close planner',
      plannerTitle: 'Plan a future session',
      plannerBody: 'Create a scheduled session and choose the room for it.',
      titleLabel: 'Title',
      description: 'Description',
      start: 'Start',
      end: 'End',
      timezone: 'Timezone',
      create: 'Create session',
      globalIcs: 'Global ICS',
      roomIcs: 'Room ICS',
      tableTitle: 'All Sessions',
      tableBody: 'Upcoming, live, and completed sessions across available rooms.',
      startCol: 'Start',
      endCol: 'End',
      sessionCol: 'Session',
      roomCol: 'Room',
      sourceCol: 'Source',
      participantsCol: 'Participants',
      durationCol: 'Duration',
      statusCol: 'Status',
      actionsCol: 'Options',
      sourcePlanner: 'Planner',
      sourceMeeting: 'BBB meeting',
      startNow: 'Start now',
      join: 'Join',
      cancel: 'Cancel',
      viewReport: 'View Report',
      details: 'Details',
      scheduled: 'Upcoming',
      live: 'Live',
      completed: 'Completed',
      statsLoaded: 'Loaded sessions',
      statsUpcoming: 'Upcoming',
      statsLive: 'Live now',
      statsCompleted: 'Completed',
      nextStart: 'Next start',
      noNextStart: 'No upcoming session',
      loading: 'Loading sessions...',
      noSessions: 'No sessions found.',
      noMatches: 'No sessions match the current filters.',
      rowsPerPage: 'Rows per page',
      page: 'Page',
      of: 'of',
      showing: 'Showing',
      previous: 'Previous',
      next: 'Next',
      close: 'Close',
      requiredFields: 'Room, title, start, and end are required.',
      createdMessage: 'Future session created.',
      startedNowMessage: 'Session started now.',
      cancelledMessage: 'Future session cancelled.',
      loadedMessage: 'session(s) loaded.',
      sessionId: 'Session ID',
      creator: 'Creator',
      descriptionFallback: 'No description provided.',
      detailRoom: 'Room',
      detailStart: 'Start',
      detailEnd: 'End',
      detailTimezone: 'Timezone',
      detailIcs: 'Room ICS',
      detailOpenRoom: 'Open room',
      futureDetailsTitle: 'Future session details',
      reportTitle: 'Session report',
      reportLoading: 'Loading session report...',
      reportEmpty: 'No session report data found.',
      reportParticipants: 'Participants',
      reportAttendance: 'Attendance score',
      reportActivity: 'Activity score',
      reportEvents: 'Events',
      reportExports: 'Exports',
      exportExcel: 'Export Excel',
      exportCsv: 'Export CSV',
      exportJson: 'Export JSON',
      detailAction: 'Detail',
      participantDetailTitle: 'Participant detail',
      participantDetailSubtitle: 'Detailed participation, attention, and attendance evidence for this session.',
      statusLabel: 'Status',
      statusStrong: 'Strong',
      statusWatch: 'Watch',
      statusRisk: 'At Risk',
      statusNoEvidence: 'No Evidence',
      attentionScore: 'Attention score',
      attnLabel: 'ATTN',
      riskLabel: 'RISK',
      engagementScore: 'Engagement score',
      activityMetric: 'Activity score',
      onlineTime: 'Online time',
      talkTime: 'Talk time',
      webcamTime: 'Webcam time',
      messagesLabel: 'Messages',
      reactionsLabel: 'Reactions',
      raiseHandsLabel: 'Raise Hands',
      whiteboardAnnotationsLabel: 'Whiteboard Annotations',
      sharedNotesLabel: 'Shared Notes',
      analyticsTab: 'Analytics',
      checksTab: 'Checks',
      attributeName: 'Attribute',
      attributeValue: 'Score / Value',
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
      schedule: 'Oturumlar',
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
      participants: 'katilimci',
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
      rooms: 'Sunucu Odalari',
      sections: 'Yonetim Alanlari',
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
      overviewTitle: 'Yonetim Ozeti',
      manageUsersTab: 'Kullanicilar',
      serverRoomsTab: 'Sunucu Odalari',
      roomConfigTab: 'Oda Yapilandirma',
      siteSettingsTab: 'Site Ayarlari',
      rolesTab: 'Roller',
      auditLogsTab: 'Denetim Kayitlari',
      manageUsersBody: 'Dogrulama, roller ve erisim icin kullanici yonetim ekranini acin.',
      serverRoomsBody: 'Tum sunucu oda envanterini inceleyin ve yonetin.',
      roomConfigBody: 'Bu alandan oda kurallari ve canli kontrolleri yonetin.',
      siteSettingsBody: 'Greenlight markalama, kayit ve platform davranisini ozellestirin.',
      rolesBody: 'Ozel roller ve izin setlerini yonetin.',
      openSection: 'Bolumu ac',
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
      title: 'Tum Kayitlar',
      body: 'Tum odalardaki kayitlari arayin, filtreleyin ve inceleyin.',
      filtersTitle: 'Kayit panosu',
      room: 'Oda',
      allRooms: 'Tum odalar',
      visibility: 'Gorunurluk',
      allVisibility: 'Tum gorunurlukler',
      search: 'Ara',
      searchPlaceholder: 'Kayit adi veya oturum ID ara',
      resetFilters: 'Filtreleri sifirla',
      tableTitle: 'Tum Kayitlar',
      tableBody: 'Erisiminiz olan tum oda ve oturum kayitlari.',
      recordingCol: 'Kayit',
      roomCol: 'Oda',
      recordedCol: 'Kayit Tarihi',
      durationCol: 'Sure',
      participantsCol: 'Katilimcilar',
      visibilityCol: 'Gorunurluk',
      formatsCol: 'Formatlar',
      actionsCol: 'Secenekler',
      open: 'Izle',
      statsTotal: 'Toplam kayit',
      statsFiltered: 'Filtrelenen sonuc',
      statsFormats: 'Mevcut format',
      statsParticipants: 'Sayfadaki katilimci',
      loading: 'Kayitlar yukleniyor...',
      noMatches: 'Mevcut filtrelerle eslesen kayit yok.',
    },
    schedulePanel: {
      title: 'Tum Oturumlar',
      body: 'Odalardaki oturumlari goruntuleyin ve yonetin.',
      filtersTitle: 'Oturum panosu',
      filtersBody: '',
      room: 'Oda',
      allRooms: 'Tum odalar',
      selectRoom: 'Oda secin',
      loadingRooms: 'Odalar yukleniyor...',
      statusFilter: 'Durum',
      allStatuses: 'Tum durumlar',
      search: 'Ara',
      searchPlaceholder: 'Baslik, aciklama, olusturan',
      resetFilters: 'Filtreleri sifirla',
      reload: 'Yenile',
      openPlanner: 'Planlayiciyi ac',
      closePlanner: 'Planlayiciyi kapat',
      plannerTitle: 'Gelecek oturum planla',
      plannerBody: 'Planli bir oturum olusturun ve hangi odada olacagini secin.',
      titleLabel: 'Baslik',
      description: 'Aciklama',
      start: 'Baslangic',
      end: 'Bitis',
      timezone: 'Saat dilimi',
      create: 'Oturum olustur',
      globalIcs: 'Genel ICS',
      roomIcs: 'Oda ICS',
      tableTitle: 'Tum Oturumlar',
      tableBody: 'Mevcut odalardaki yaklasan, canli ve tamamlanan oturumlar.',
      startCol: 'Baslangic',
      endCol: 'Bitis',
      sessionCol: 'Oturum',
      roomCol: 'Oda',
      sourceCol: 'Kaynak',
      participantsCol: 'Katilimci',
      durationCol: 'Sure',
      statusCol: 'Durum',
      actionsCol: 'Secenekler',
      sourcePlanner: 'Planlayici',
      sourceMeeting: 'BBB toplanti',
      startNow: 'Simdi baslat',
      join: 'Katil',
      cancel: 'Iptal',
      viewReport: 'Raporu gor',
      details: 'Detaylar',
      scheduled: 'Yaklasan',
      live: 'Canli',
      completed: 'Tamamlandi',
      statsLoaded: 'Yuklenen oturum',
      statsUpcoming: 'Yaklasan',
      statsLive: 'Simdi canli',
      statsCompleted: 'Tamamlanan',
      nextStart: 'Siradaki baslangic',
      noNextStart: 'Yaklasan oturum yok',
      loading: 'Oturumlar yukleniyor...',
      noSessions: 'Oturum bulunamadi.',
      noMatches: 'Mevcut filtrelerle eslesen oturum yok.',
      rowsPerPage: 'Sayfa basi satir',
      page: 'Sayfa',
      of: '/',
      showing: 'Gosterilen',
      previous: 'Onceki',
      next: 'Sonraki',
      close: 'Kapat',
      requiredFields: 'Oda, baslik, baslangic ve bitis zorunludur.',
      createdMessage: 'Gelecek oturum olusturuldu.',
      startedNowMessage: 'Oturum simdi baslatildi.',
      cancelledMessage: 'Gelecek oturum iptal edildi.',
      loadedMessage: 'oturum yuklendi.',
      sessionId: 'Oturum ID',
      creator: 'Olusturan',
      descriptionFallback: 'Aciklama girilmedi.',
      detailRoom: 'Oda',
      detailStart: 'Baslangic',
      detailEnd: 'Bitis',
      detailTimezone: 'Saat dilimi',
      detailIcs: 'Oda ICS',
      detailOpenRoom: 'Odayi ac',
      futureDetailsTitle: 'Gelecek oturum detaylari',
      reportTitle: 'Oturum raporu',
      reportLoading: 'Oturum raporu yukleniyor...',
      reportEmpty: 'Oturum raporu verisi bulunamadi.',
      reportParticipants: 'Katilimcilar',
      reportAttendance: 'Yoklama skoru',
      reportActivity: 'Aktivite skoru',
      reportEvents: 'Etkinlikler',
      reportExports: 'Disa aktarimlar',
      exportExcel: 'Excel indir',
      exportCsv: 'CSV indir',
      exportJson: 'JSON indir',
      detailAction: 'Detay',
      participantDetailTitle: 'Katilimci detayi',
      participantDetailSubtitle: 'Bu oturum icin ayrintili katilim, dikkat ve devam kanitlari.',
      statusLabel: 'Durum',
      statusStrong: 'Guclu',
      statusWatch: 'Izle',
      statusRisk: 'Riskli',
      statusNoEvidence: 'Kanit Yok',
      attentionScore: 'Dikkat skoru',
      attnLabel: 'ATTN',
      riskLabel: 'RISK',
      engagementScore: 'Etkilesim skoru',
      activityMetric: 'Aktivite skoru',
      onlineTime: 'Cevrimici sure',
      talkTime: 'Konusma suresi',
      webcamTime: 'Webcam suresi',
      messagesLabel: 'Mesajlar',
      reactionsLabel: 'Tepkiler',
      raiseHandsLabel: 'El Kaldirma',
      whiteboardAnnotationsLabel: 'Beyaz Tahta Notlari',
      sharedNotesLabel: 'Paylasilan Notlar',
      analyticsTab: 'Analitik',
      checksTab: 'Kontroller',
      attributeName: 'Ozellik',
      attributeValue: 'Skor / Deger',
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

function WorkspaceTableFooter({
  page,
  rowsPerPage,
  totalItems,
  onPageChange,
  onRowsChange,
  copy,
  pageSizes = [10, 25, 50],
}) {
  const totalPages = Math.max(Math.ceil(totalItems / rowsPerPage), 1);
  const startItem = totalItems ? (((page - 1) * rowsPerPage) + 1) : 0;
  const endItem = totalItems ? Math.min(page * rowsPerPage, totalItems) : 0;

  return (
    <div className="ak-workspace-table-footer">
      <div className="ak-workspace-table-footer-meta">
        <span>
          {copy.showing}
          {' '}
          {startItem}-{endItem}
          {' '}
          {copy.of}
          {' '}
          {totalItems}
        </span>
        <label className="ak-workspace-table-footer-rows">
          <span>{copy.rowsPerPage}</span>
          <select
            className="ak-workspace-select"
            value={rowsPerPage}
            onChange={(event) => onRowsChange(parseInt(event.target.value, 10))}
          >
            {pageSizes.map((size) => (
              <option key={size} value={size}>{size}</option>
            ))}
          </select>
        </label>
      </div>

      <div className="ak-workspace-table-footer-controls">
        <span className="ak-workspace-table-footer-page">
          {copy.page}
          {' '}
          {page}
          {' '}
          {copy.of}
          {' '}
          {totalPages}
        </span>
        <button
          type="button"
          className="ak-workspace-table-page-btn"
          onClick={() => onPageChange(Math.max(page - 1, 1))}
          disabled={page <= 1}
        >
          {copy.previous}
        </button>
        <button
          type="button"
          className="ak-workspace-table-page-btn"
          onClick={() => onPageChange(Math.min(page + 1, totalPages))}
          disabled={page >= totalPages}
        >
          {copy.next}
        </button>
      </div>
    </div>
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

function formatRangeDuration(startAt, endAt, language = 'en') {
  const start = new Date(startAt).getTime();
  const end = new Date(endAt).getTime();

  if (Number.isNaN(start) || Number.isNaN(end) || end <= start) return '-';

  return formatDuration(Math.round((end - start) / 1000), language);
}

function formatDateOnly(value, language) {
  if (!value) return '-';

  try {
    return new Intl.DateTimeFormat(
      language === 'tr' ? 'tr-TR' : 'en-US',
      { dateStyle: 'medium' },
    ).format(new Date(value));
  } catch (_) {
    return value;
  }
}

function safeNumber(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
}

function isActiveFlag(value) {
  if (value === true || value === 1) return true;
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase();
    return ['true', 't', '1', 'yes', 'y', 'on'].includes(normalized);
  }
  return false;
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
    `${row.attentionScore}%`,
    `${row.engagementScore}%`,
    `${row.activityScore}%`,
    row.finalScore,
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
  const objectUrl = URL.createObjectURL(blob);

  link.href = objectUrl;
  link.download = `${filePrefix || 'session-report'}-${meetingSlug || 'report'}.xls`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(objectUrl);
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
            <tr key={`${row.label}-${index + 1}`}>
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

function getRoomName(roomId, roomDirectory) {
  if (!roomId) return '-';
  return roomDirectory?.get(roomId)?.name || '-';
}

function buildRoomOptions(primaryRooms = [], roomDirectory, mode = 'friendly') {
  const unique = new Map();

  primaryRooms.forEach((room) => {
    const roomId = mode === 'meeting'
      ? (room?.meeting_id || room?.meeting_ext_id || room?.room || room?.friendly_id || room?.id)
      : (room?.friendly_id || room?.id || room?.meeting_id || room?.room || room?.meeting_ext_id);
    if (!roomId || unique.has(roomId)) return;
    unique.set(roomId, {
      id: roomId,
      name: room?.name || getRoomName(roomId, roomDirectory),
    });
  });

  roomDirectory?.forEach((room, roomId) => {
    if (unique.has(roomId)) return;
    unique.set(roomId, {
      id: roomId,
      name: room?.name || roomId,
    });
  });

  return [...unique.values()].sort((left, right) => left.name.localeCompare(right.name));
}

function getFriendlyRoomId(roomId, roomDirectory) {
  if (!roomId) return '';
  return roomDirectory?.get(roomId)?.friendly_id || '';
}

function getPreferredRecordingUrl(recording) {
  if (!Array.isArray(recording?.formats)) return '';
  const preferredFormat = recording.formats.find((format) => !!format?.url);
  return preferredFormat?.url || '';
}

function getScheduledSessionState(meeting, copy, now = Date.now()) {
  const metadata = meeting?.metadata && typeof meeting.metadata === 'object' ? meeting.metadata : {};
  const hasLiveEvidence = (
    isActiveFlag(meeting?.is_active)
    || isActiveFlag(metadata?.is_active)
  );

  const end = new Date(meeting?.end_at || '').getTime();

  if (hasLiveEvidence) {
    return {
      key: 'live',
      label: copy.live,
      className: 'is-ok',
    };
  }

  if (!Number.isNaN(end) && end < now) {
    return {
      key: 'completed',
      label: copy.completed,
      className: 'is-neutral',
    };
  }

  return {
    key: 'scheduled',
    label: copy.scheduled,
    className: 'is-warn',
  };
}

function normalizeExtError(error) {
  if (error instanceof Error && error.message) return error.message;
  return 'Request failed.';
}

function normalizeObjectList(value) {
  if (!Array.isArray(value)) return [];
  return value.filter((item) => item && typeof item === 'object');
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

function ScheduleWorkspace({
  copy, language, actorName, availableRooms, roomDirectory,
}) {
  const scheduleCopy = copy.schedulePanel;
  const roomOptions = useMemo(() => buildRoomOptions(availableRooms, roomDirectory, 'meeting'), [availableRooms, roomDirectory]);
  const allRoomIds = useMemo(() => roomOptions.map((room) => room.id), [roomOptions]);
  const [selectedRoom, setSelectedRoom] = useState('');
  const [scheduledMeetings, setScheduledMeetings] = useState([]);
  const [recentMeetings, setRecentMeetings] = useState([]);
  const [status, setStatus] = useState({ message: '', error: false });
  const [loadingSessions, setLoadingSessions] = useState(false);
  const [showPlannerModal, setShowPlannerModal] = useState(false);
  const [showReportModal, setShowReportModal] = useState(false);
  const [statusFilter, setStatusFilter] = useState('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [tablePage, setTablePage] = useState(1);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [reportMeeting, setReportMeeting] = useState(null);
  const [reportLoading, setReportLoading] = useState(false);
  const [reportStatus, setReportStatus] = useState({ message: '', error: false });
  const [reportSummary, setReportSummary] = useState(null);
  const [reportUsers, setReportUsers] = useState([]);
  const [reportChecks, setReportChecks] = useState([]);
  const [reportTimeline, setReportTimeline] = useState([]);
  const [reportAttention, setReportAttention] = useState([]);
  const [selectedParticipantKey, setSelectedParticipantKey] = useState('');
  const [showParticipantModal, setShowParticipantModal] = useState(false);
  const [participantDetailTab, setParticipantDetailTab] = useState('analytics');
  const [form, setForm] = useState({
    room: '',
    title: '',
    description: '',
    startAt: '',
    endAt: '',
    timezone: 'Europe/Istanbul',
  });

  useEffect(() => {
    if (!roomOptions.length) return;

    setForm((prev) => {
      if (prev.room) return prev;
      return {
        ...prev,
        room: selectedRoom || roomOptions[0].id,
      };
    });
  }, [roomOptions, selectedRoom]);

  useEffect(() => {
    if (!selectedRoom) return;

    setForm((prev) => {
      if (prev.room === selectedRoom) return prev;
      return {
        ...prev,
        room: selectedRoom,
      };
    });
  }, [selectedRoom]);

  const loadAllSessions = useCallback(async (roomId = selectedRoom, silent = false) => {
    const roomIds = roomId ? [roomId] : allRoomIds;

    if (!roomIds.length) {
      setScheduledMeetings([]);
      setRecentMeetings([]);
      if (!silent) setStatus({ message: '', error: false });
      return;
    }

    setLoadingSessions(true);
    try {
      const recentParams = new URLSearchParams();
      recentParams.set('limit', '500');
      recentParams.set('includeEnded', '1');
      if (roomId) recentParams.set('room', roomId);

      const [scheduled, recent] = await Promise.all([
        Promise.all(
          roomIds.map(async (currentRoomId) => {
            const data = await fetchExtJson(`/ext/future-meetings?room=${encodeURIComponent(currentRoomId)}&limit=200&includePast=1`);
            return normalizeObjectList(data.future_meetings).map((meeting) => ({
              ...meeting,
              room: meeting.room || currentRoomId,
            }));
          }),
        ).then((items) => items.flat()),
        fetchExtJson(`/ext/recent-meetings?${recentParams.toString()}`).then((data) => normalizeObjectList(data.meetings)),
      ]);

      setScheduledMeetings(scheduled);
      setRecentMeetings(recent);
      if (!silent) {
        setStatus({ message: `${scheduled.length + recent.length} ${scheduleCopy.loadedMessage}`, error: false });
      }
    } catch (err) {
      setScheduledMeetings([]);
      setRecentMeetings([]);
      setStatus({ message: normalizeExtError(err), error: true });
    } finally {
      setLoadingSessions(false);
    }
  }, [allRoomIds, scheduleCopy.loadedMessage, selectedRoom]);

  useEffect(() => {
    loadAllSessions(selectedRoom);
  }, [loadAllSessions, selectedRoom]);

  const setField = (key, value) => {
    setForm((prev) => ({ ...prev, [key]: value }));
  };

  const createMeeting = async (event) => {
    event.preventDefault();
    if (!form.room || !form.startAt || !form.endAt || !form.title.trim()) {
      setStatus({ message: scheduleCopy.requiredFields, error: true });
      return;
    }

    try {
      await fetchExtJson('/ext/future-meetings/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          room: form.room,
          title: form.title.trim(),
          description: form.description.trim(),
          start_at: new Date(form.startAt).toISOString(),
          end_at: new Date(form.endAt).toISOString(),
          timezone: form.timezone || 'Europe/Istanbul',
          created_by: actorName,
          metadata: { source: 'greenlight-workspace' },
        }),
      });

      setStatus({ message: scheduleCopy.createdMessage, error: false });
      setForm((prev) => ({
        ...prev,
        title: '',
        description: '',
        startAt: '',
        endAt: '',
      }));
      setShowPlannerModal(false);
      await loadAllSessions(selectedRoom, true);
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
      await loadAllSessions(selectedRoom, true);
      setStatus({ message: scheduleCopy.cancelledMessage, error: false });
    } catch (err) {
      setStatus({ message: normalizeExtError(err), error: true });
    }
  };

  const startScheduledMeetingNow = async (meeting) => {
    if (!meeting?.scheduleId) return;

    try {
      let joinUrl = meeting.openHref || '';

      if (meeting.roomRouteId) {
        const response = await axios.post(`/meetings/${meeting.roomRouteId}/start.json`);
        joinUrl = response?.data?.data || joinUrl;
      }

      await fetchExtJson('/ext/future-meetings/cancel', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: String(meeting.scheduleId) }),
      });

      await loadAllSessions(selectedRoom, true);
      setStatus({ message: scheduleCopy.startedNowMessage, error: false });

      if (joinUrl) {
        window.open(joinUrl, '_blank', 'noopener,noreferrer');
      }
    } catch (err) {
      setStatus({ message: normalizeExtError(err), error: true });
    }
  };

  const openMeetingReport = useCallback(async (meeting) => {
    if (!meeting?.meetingIntId) return;

    setReportMeeting(meeting);
    setShowReportModal(true);
    setReportLoading(true);
    setReportStatus({ message: '', error: false });

    try {
      const [usersData, summaryData, checksData, timelineData, attentionData] = await Promise.all([
        fetchExtJson(`/ext/past-meeting-users?meeting_int_id=${encodeURIComponent(meeting.meetingIntId)}`),
        fetchExtJson(`/ext/engagement-summary?meeting_int_id=${encodeURIComponent(meeting.meetingIntId)}`),
        fetchExtJson(`/ext/meeting-checks/user-summary?meeting_int_id=${encodeURIComponent(meeting.meetingIntId)}`),
        fetchExtJson(`/ext/engagement-timeline?meeting_int_id=${encodeURIComponent(meeting.meetingIntId)}&limit=240`),
        fetchExtJson(`/ext/attention-score?meeting_int_id=${encodeURIComponent(meeting.meetingIntId)}&limit=500`),
      ]);

      setReportUsers(normalizeObjectList(usersData.users));
      setReportSummary(summaryData || null);
      setReportChecks(normalizeObjectList(checksData.users));
      setReportTimeline(normalizeObjectList(timelineData.events));
      setReportAttention(normalizeObjectList(attentionData.users));
      setSelectedParticipantKey('');
      setShowParticipantModal(false);
    } catch (err) {
      setReportUsers([]);
      setReportSummary(null);
      setReportChecks([]);
      setReportTimeline([]);
      setReportAttention([]);
      setReportStatus({ message: normalizeExtError(err), error: true });
    } finally {
      setReportLoading(false);
    }
  }, []);

  const sessionRows = useMemo(() => {
    const activeActualRooms = new Set(
      recentMeetings
        .filter((meeting) => isActiveFlag(meeting.is_active) && meeting.meeting_ext_id)
        .map((meeting) => meeting.meeting_ext_id),
    );

    const plannedRows = scheduledMeetings
      .map((meeting) => {
        const sessionState = getScheduledSessionState(meeting, scheduleCopy);
        const roomId = meeting.room || '';
        const roomName = getRoomName(roomId, roomDirectory);
        const roomRouteId = getFriendlyRoomId(roomId, roomDirectory);

        return {
          id: `scheduled-${meeting.id}`,
          rowKind: 'scheduled',
          scheduleId: String(meeting.id || ''),
          meetingIntId: '',
          startAt: meeting.start_at,
          endAt: meeting.end_at,
          title: meeting.title || '-',
          sessionId: meeting.id ? String(meeting.id) : '-',
          roomId,
          roomName,
          sourceLabel: scheduleCopy.sourcePlanner,
          participantsLabel: '-',
          durationLabel: formatRangeDuration(meeting.start_at, meeting.end_at, language),
          sessionState,
          roomRouteId,
          openHref: sessionState.key === 'live'
            ? (meeting.join_url || (roomRouteId ? `/rooms/${roomRouteId}` : ''))
            : '',
          canStartNow: sessionState.key === 'scheduled',
          canCancel: sessionState.key === 'scheduled',
          canJoin: sessionState.key === 'live',
          canReport: false,
          creator: meeting.created_by || actorName || '-',
          description: meeting.description || '',
          timezone: meeting.timezone || 'Europe/Istanbul',
          icsHref: roomId ? `/ext/future-meetings/ics?room=${encodeURIComponent(roomId)}` : '/ext/future-meetings/ics/all',
          searchValue: [
            meeting.title,
            meeting.description,
            meeting.created_by,
            meeting.room,
            roomName,
            meeting.timezone,
            meeting.id,
          ]
            .filter(Boolean)
            .join(' ')
            .toLowerCase(),
        };
      })
      .filter((meeting) => meeting.sessionState.key !== 'completed')
      .filter((meeting) => !(meeting.sessionState.key === 'live' && activeActualRooms.has(meeting.roomId)));

    const actualRows = recentMeetings.map((meeting) => {
      const roomId = meeting.meeting_ext_id || '';
      const roomName = getRoomName(roomId, roomDirectory);
      const roomRouteId = getFriendlyRoomId(roomId, roomDirectory);
      const isLive = isActiveFlag(meeting.is_active);

      return {
        id: `actual-${meeting.meeting_int_id}`,
        rowKind: 'actual',
        scheduleId: '',
        meetingIntId: meeting.meeting_int_id || '',
        startAt: meeting.created_at,
        endAt: meeting.ended_at,
        title: meeting.meeting_name || meeting.meeting_int_id || '-',
        sessionId: meeting.meeting_int_id || '-',
        roomId,
        roomName,
        sourceLabel: scheduleCopy.sourceMeeting,
        participantsLabel: safeNumber(meeting.participants_count),
        durationLabel: isLive
          ? formatRangeDuration(meeting.created_at, new Date().toISOString(), language)
          : formatRangeDuration(meeting.created_at, meeting.ended_at, language),
        roomRouteId,
        sessionState: isLive
          ? { key: 'live', label: scheduleCopy.live, className: 'is-ok' }
          : { key: 'completed', label: scheduleCopy.completed, className: 'is-neutral' },
        openHref: isLive && roomRouteId ? `/rooms/${roomRouteId}` : '',
        canStartNow: false,
        canCancel: false,
        canJoin: isLive,
        canReport: !isLive,
        creator: '-',
        description: '',
        timezone: '-',
        icsHref: roomId ? `/ext/future-meetings/ics?room=${encodeURIComponent(roomId)}` : '',
        searchValue: [
          meeting.meeting_name,
          meeting.meeting_int_id,
          meeting.meeting_ext_id,
          roomName,
        ]
          .filter(Boolean)
          .join(' ')
          .toLowerCase(),
      };
    });

    return [...actualRows, ...plannedRows].sort((left, right) => {
      const rank = { live: 0, scheduled: 1, completed: 2 };
      const leftRank = rank[left.sessionState.key] ?? 99;
      const rightRank = rank[right.sessionState.key] ?? 99;

      if (leftRank !== rightRank) return leftRank - rightRank;

      const leftTime = new Date(left.startAt).getTime() || 0;
      const rightTime = new Date(right.startAt).getTime() || 0;

      if (left.sessionState.key === 'completed') return rightTime - leftTime;
      return leftTime - rightTime;
    });
  }, [actorName, language, recentMeetings, roomDirectory, scheduleCopy, scheduledMeetings]);

  const filteredMeetings = useMemo(() => {
    const searchValue = searchTerm.trim().toLowerCase();

    return sessionRows.filter((meeting) => {
      const matchesRoom = !selectedRoom || meeting.roomId === selectedRoom;
      const matchesStatus = statusFilter === 'all' || meeting.sessionState.key === statusFilter;
      const matchesSearch = !searchValue || meeting.searchValue.includes(searchValue);
      return matchesRoom && matchesStatus && matchesSearch;
    });
  }, [searchTerm, selectedRoom, sessionRows, statusFilter]);

  const sessionStats = useMemo(() => {
    const upcoming = sessionRows.filter((meeting) => meeting.sessionState.key === 'scheduled');
    const live = sessionRows.filter((meeting) => meeting.sessionState.key === 'live');
    const completed = sessionRows.filter((meeting) => meeting.sessionState.key === 'completed');
    const nextUpcoming = [...upcoming]
      .sort((left, right) => new Date(left.startAt).getTime() - new Date(right.startAt).getTime())[0];

    return {
      total: sessionRows.length,
      upcoming: upcoming.length,
      live: live.length,
      completed: completed.length,
      nextUpcoming,
    };
  }, [sessionRows]);

  const reportMetrics = useMemo(() => {
    const attendance = reportSummary?.attendance || {};
    const engagement = reportSummary?.engagement || {};
    const checksOk = safeNumber(attendance.checks_ok);
    const checksLate = safeNumber(attendance.checks_late);
    const checksMissed = safeNumber(attendance.checks_missed);
    const totalChecks = checksOk + checksLate + checksMissed;
    const focusTotal = reportAttention.reduce((sum, user) => sum + safeNumber(user.focus_count), 0);
    const blurTotal = reportAttention.reduce((sum, user) => sum + safeNumber(user.blur_count), 0);
    const scoreValues = reportAttention
      .map((user) => safeNumber(user.compliance_score))
      .filter((value) => value > 0);
    const attentionScore = scoreValues.length
      ? Math.round(scoreValues.reduce((sum, value) => sum + value, 0) / scoreValues.length)
      : safeNumber(engagement.attention_score);
    const activityScore = safeNumber(engagement.activity_score)
      || Math.min(100, Math.round((reportTimeline.length / Math.max(safeNumber(attendance.participants_count) || 1, 1)) * 10));

    return {
      participants: safeNumber(attendance.participants_count) || reportUsers.length,
      attendanceScore: totalChecks > 0
        ? Math.round(((checksOk + (checksLate * 0.5)) / totalChecks) * 100)
        : 0,
      attentionScore,
      activityScore,
      events: safeNumber(engagement.events_total),
      focusRate: (focusTotal + blurTotal) > 0
        ? Math.round((focusTotal / (focusTotal + blurTotal)) * 100)
        : 0,
    };
  }, [reportAttention, reportSummary, reportTimeline.length, reportUsers.length]);

  const reportParticipantRows = useMemo(() => {
    const timelineByUser = new Map();
    const meetingEnd = reportMeeting?.endAt ? new Date(reportMeeting.endAt) : null;

    reportTimeline.forEach((event) => {
      const key = `${event.user_id || ''}-${event.name || ''}`;
      const bucket = timelineByUser.get(key) || {
        joins: [],
        leaves: [],
        chatCount: 0,
        pollAnswers: 0,
        raiseHands: 0,
        lowerHands: 0,
        reactionCount: 0,
        whiteboardAnnotationsCount: 0,
        sharedNotesCount: 0,
        eventCount: 0,
      };
      const eventAt = event.event_at ? new Date(event.event_at) : null;
      const eventType = `${event.event_type || ''}`.toLowerCase();

      if (eventType === 'join' && eventAt && !Number.isNaN(eventAt.getTime())) bucket.joins.push(eventAt);
      if (eventType === 'leave' && eventAt && !Number.isNaN(eventAt.getTime())) bucket.leaves.push(eventAt);
      if (eventType === 'chat') bucket.chatCount += 1;
      if (eventType === 'poll_answered') bucket.pollAnswers += 1;
      if (eventType === 'raise_hand') bucket.raiseHands += 1;
      if (eventType === 'lower_hand') bucket.lowerHands += 1;
      if (eventType === 'reaction') bucket.reactionCount += 1;
      if (eventType === 'whiteboard_annotation') bucket.whiteboardAnnotationsCount += 1;
      if (eventType === 'shared_notes') bucket.sharedNotesCount += 1;
      if (eventType) bucket.eventCount += 1;

      timelineByUser.set(key, bucket);
    });

    const rowMap = new Map();

    reportChecks.forEach((user) => {
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
        genericChecksTotal: 0,
        genericChecksOk: 0,
        genericChecksLate: 0,
        genericChecksMissed: 0,
        quizTotal: safeNumber(user.quiz_total),
        quizOk: safeNumber(user.quiz_ok),
        quizFailed: safeNumber(user.quiz_failed),
        quizLate: safeNumber(user.quiz_late),
        quizMissed: safeNumber(user.quiz_missed),
        focusCount: 0,
        blurCount: 0,
        idleCount: 0,
        activeCount: 0,
        talkSeconds: 0,
        webcamSeconds: 0,
        score: 0,
        firstCheckAt: user.first_check_at || '',
        lastCheckAt: user.last_check_at || '',
      });
    });

    reportUsers.forEach((user) => {
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
        genericChecksTotal: 0,
        genericChecksOk: 0,
        genericChecksLate: 0,
        genericChecksMissed: 0,
        quizTotal: 0,
        quizOk: 0,
        quizFailed: 0,
        quizLate: 0,
        quizMissed: 0,
        focusCount: 0,
        blurCount: 0,
        idleCount: 0,
        activeCount: 0,
        talkSeconds: 0,
        webcamSeconds: 0,
        score: 0,
        firstCheckAt: '',
        lastCheckAt: '',
      };

      existing.user = user.name || existing.user;
      existing.userId = user.user_id || existing.userId;
      existing.role = user.role || existing.role;
      existing.genericChecksTotal = safeNumber(user.checks_total);
      existing.genericChecksOk = safeNumber(user.checks_ok);
      existing.genericChecksLate = safeNumber(user.checks_late);
      existing.genericChecksMissed = safeNumber(user.checks_missed);
      existing.firstCheckAt = user.first_check_at || existing.firstCheckAt;
      existing.lastCheckAt = user.last_check_at || existing.lastCheckAt;
      existing.talkSeconds = safeNumber(
        user.talk_seconds
        || user.talk_time_seconds
        || user.talk_time
        || user.talkTimeSeconds
        || user.talkTime,
      );
      existing.webcamSeconds = safeNumber(
        user.webcam_seconds
        || user.webcam_time_seconds
        || user.webcam_time
        || user.webcamTimeSeconds
        || user.webcamTime,
      );
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
        genericChecksTotal: 0,
        genericChecksOk: 0,
        genericChecksLate: 0,
        genericChecksMissed: 0,
        quizTotal: 0,
        quizOk: 0,
        quizFailed: 0,
        quizLate: 0,
        quizMissed: 0,
        focusCount: 0,
        blurCount: 0,
        idleCount: 0,
        activeCount: 0,
        talkSeconds: 0,
        webcamSeconds: 0,
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
      existing.focusCount = safeNumber(user.focus_count);
      existing.blurCount = safeNumber(user.blur_count);
      existing.idleCount = safeNumber(user.idle_count);
      existing.activeCount = safeNumber(user.active_count);
      existing.score = safeNumber(user.compliance_score);
      existing.talkSeconds = safeNumber(
        user.talk_seconds
        || user.talk_time_seconds
        || user.talk_time
        || user.talkTimeSeconds
        || user.talkTime,
      ) || existing.talkSeconds;
      existing.webcamSeconds = safeNumber(
        user.webcam_seconds
        || user.webcam_time_seconds
        || user.webcam_time
        || user.webcamTimeSeconds
        || user.webcamTime,
      ) || existing.webcamSeconds;
      rowMap.set(key, existing);
    });

    return [...rowMap.values()]
      .map((row) => {
        const timeline = timelineByUser.get(row.key) || {
          joins: [],
          leaves: [],
          chatCount: 0,
          pollAnswers: 0,
          raiseHands: 0,
          lowerHands: 0,
          reactionCount: 0,
          whiteboardAnnotationsCount: 0,
          sharedNotesCount: 0,
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
        const quizNok = row.quizFailed + row.quizLate + row.quizMissed;
        const attendanceOnlyScore = attendanceTotal > 0
          ? Math.round(((attendanceOk + (attendanceLate * 0.5)) / attendanceTotal) * 100)
          : 0;
        const quizOnlyScore = quizTotal > 0
          ? Math.round(((quizOk + (row.quizLate * 0.5)) / quizTotal) * 100)
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
        const attentionScore = row.score > 0
          ? row.score
          : Math.round((attendanceScore * 0.45) + (focusRate * 0.25) + (activityScore * 0.3));
        const combinedChecksTotal = attendanceTotal + quizTotal;
        const combinedChecksPassed = attendanceOk + quizOk;
        const checkPassRate = combinedChecksTotal > 0
          ? Math.round((combinedChecksPassed / combinedChecksTotal) * 100)
          : 0;
        const finalScore = row.score > 0 ? row.score : attentionScore;

        let statusLabel = finalScore >= 85 ? scheduleCopy.statusStrong : finalScore >= 60 ? scheduleCopy.statusWatch : scheduleCopy.statusRisk;
        let statusClass = finalScore >= 85 ? 'is-ok' : finalScore >= 60 ? 'is-warn' : 'is-bad';

        if (reportMeeting?.durationLabel !== '-' && onlineSeconds === 0 && combinedChecksTotal === 0) {
          statusLabel = scheduleCopy.statusNoEvidence;
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
          quizNok,
          firstJoinAt,
          lastLeaveAt,
          onlineSeconds,
          attendanceScore,
          attentionScore,
          engagementScore,
          activityScore,
          focusRate,
          checkPassRate,
          chatCount: timeline.chatCount,
          pollAnswers: timeline.pollAnswers,
          raiseHands: timeline.raiseHands,
          lowerHands: timeline.lowerHands,
          reactionCount: timeline.reactionCount,
          whiteboardAnnotationsCount: timeline.whiteboardAnnotationsCount,
          sharedNotesCount: timeline.sharedNotesCount,
          activityEvents: timeline.eventCount,
          talkSeconds: row.talkSeconds,
          webcamSeconds: row.webcamSeconds,
          statusLabel,
          statusClass,
          finalScore,
        };
      })
      .sort((left, right) => right.engagementScore - left.engagementScore || left.user.localeCompare(right.user));
  }, [
    reportAttention,
    reportChecks,
    reportMeeting?.durationLabel,
    reportTimeline,
    reportUsers,
    scheduleCopy.statusNoEvidence,
    scheduleCopy.statusRisk,
    scheduleCopy.statusStrong,
    scheduleCopy.statusWatch,
  ]);
  const selectedParticipantRow = useMemo(
    () => reportParticipantRows.find((row) => row.key === selectedParticipantKey) || null,
    [reportParticipantRows, selectedParticipantKey],
  );

  useEffect(() => {
    if (showParticipantModal) {
      setParticipantDetailTab('analytics');
    }
  }, [selectedParticipantKey, showParticipantModal]);

  useEffect(() => {
    setTablePage(1);
  }, [rowsPerPage, searchTerm, selectedRoom, statusFilter]);

  const totalPages = Math.max(Math.ceil(filteredMeetings.length / rowsPerPage), 1);
  const safePage = Math.min(tablePage, totalPages);

  useEffect(() => {
    if (tablePage !== safePage) {
      setTablePage(safePage);
    }
  }, [safePage, tablePage]);

  const pagedMeetings = useMemo(() => {
    const startIndex = (safePage - 1) * rowsPerPage;
    return filteredMeetings.slice(startIndex, startIndex + rowsPerPage);
  }, [filteredMeetings, rowsPerPage, safePage]);

  const roomIcsHref = selectedRoom ? `/ext/future-meetings/ics?room=${encodeURIComponent(selectedRoom)}` : '';
  const hasActiveFilters = !!selectedRoom || statusFilter !== 'all' || !!searchTerm.trim();
  const reportCsvHref = reportMeeting?.meetingIntId ? `/ext/export/attendance.csv?meeting_int_id=${encodeURIComponent(reportMeeting.meetingIntId)}&includeChecks=1` : '';
  const reportJsonHref = reportMeeting?.meetingIntId ? `/ext/export/attendance.json?meeting_int_id=${encodeURIComponent(reportMeeting.meetingIntId)}&includeChecks=1` : '';
  const participantAnalyticsRows = selectedParticipantRow ? [
    { label: scheduleCopy.sessionId, value: reportMeeting?.sessionId || '-' },
    { label: scheduleCopy.creator, value: reportMeeting?.creator || '-' },
    { label: copy.recordingsDetail.user, value: selectedParticipantRow.user || '-' },
    { label: scheduleCopy.statusLabel, value: selectedParticipantRow.statusLabel || '-' },
    {
      label: scheduleCopy.riskLabel,
      value: selectedParticipantRow.statusClass === 'is-bad'
        ? scheduleCopy.statusRisk
        : selectedParticipantRow.statusClass === 'is-warn'
          ? scheduleCopy.statusWatch
          : scheduleCopy.statusStrong,
    },
    { label: scheduleCopy.start, value: formatDateTime(selectedParticipantRow.firstJoinAt, language) },
    { label: scheduleCopy.end, value: formatDateTime(selectedParticipantRow.lastLeaveAt, language) },
    { label: scheduleCopy.onlineTime, value: formatDuration(selectedParticipantRow.onlineSeconds, language) },
    { label: scheduleCopy.talkTime, value: formatDuration(selectedParticipantRow.talkSeconds, language) },
    { label: scheduleCopy.webcamTime, value: formatDuration(selectedParticipantRow.webcamSeconds, language) },
    { label: scheduleCopy.attnLabel, value: `${selectedParticipantRow.attentionScore}%` },
    { label: scheduleCopy.attentionScore, value: `${selectedParticipantRow.attentionScore}%` },
    { label: scheduleCopy.engagementScore, value: `${selectedParticipantRow.engagementScore}%` },
    { label: scheduleCopy.activityMetric, value: `${selectedParticipantRow.activityScore}%` },
  ] : [];
  const participantChecksRows = selectedParticipantRow ? [
    { label: scheduleCopy.talkTime, value: formatDuration(selectedParticipantRow.talkSeconds, language) },
    { label: scheduleCopy.webcamTime, value: formatDuration(selectedParticipantRow.webcamSeconds, language) },
    { label: 'ATT Total', value: selectedParticipantRow.attendanceTotal },
    { label: 'ATT OK', value: selectedParticipantRow.attendanceOk },
    { label: 'ATT LATE', value: selectedParticipantRow.attendanceLate },
    { label: 'ATT MISSED', value: selectedParticipantRow.attendanceMissed },
    { label: 'QUIZ Total', value: selectedParticipantRow.quizTotal },
    { label: 'QUIZ OK', value: selectedParticipantRow.quizOk },
    { label: 'QUIZ NOK', value: selectedParticipantRow.quizNok },
    { label: scheduleCopy.messagesLabel, value: selectedParticipantRow.chatCount },
    { label: scheduleCopy.reactionsLabel, value: safeNumber(selectedParticipantRow.reactionCount) },
    { label: 'Polls', value: selectedParticipantRow.pollAnswers },
    { label: scheduleCopy.raiseHandsLabel, value: `${selectedParticipantRow.raiseHands}/${selectedParticipantRow.lowerHands}` },
    { label: scheduleCopy.whiteboardAnnotationsLabel, value: safeNumber(selectedParticipantRow.whiteboardAnnotationsCount) },
    { label: scheduleCopy.sharedNotesLabel, value: safeNumber(selectedParticipantRow.sharedNotesCount) },
    { label: 'Focus / Blur', value: `${selectedParticipantRow.focusCount}/${selectedParticipantRow.blurCount}` },
    { label: scheduleCopy.reportAttendance, value: `${selectedParticipantRow.attendanceScore}%` },
  ] : [];
  const participantDetailTabs = [
    {
      key: 'analytics',
      label: scheduleCopy.analyticsTab,
      rows: participantAnalyticsRows,
      meta: `${scheduleCopy.reportParticipants}: ${selectedParticipantRow ? selectedParticipantRow.user : '-'}`,
    },
    {
      key: 'checks',
      label: scheduleCopy.checksTab,
      rows: participantChecksRows,
      meta: `${scheduleCopy.reportAttendance}: ${selectedParticipantRow ? `${selectedParticipantRow.attendanceScore}%` : '-'}`,
    },
  ];
  const activeParticipantDetailTab = participantDetailTabs.find((tab) => tab.key === participantDetailTab) || participantDetailTabs[0];

  return (
    <>
      <div className="ak-workspace-panel ak-workspace-sessions">
        <PanelIntro eyebrow={copy.tabs.schedule} title={scheduleCopy.title} body={scheduleCopy.body} />

        <section className="ak-workspace-tool-card ak-workspace-schedule-board">
          <div className="ak-workspace-tool-head">
            <h3>{scheduleCopy.filtersTitle}</h3>
            {scheduleCopy.filtersBody && <p>{scheduleCopy.filtersBody}</p>}
          </div>

          <div className="ak-workspace-form-grid ak-workspace-form-grid-schedule">
            <label className="ak-workspace-field">
              <span>{scheduleCopy.room}</span>
              <select className="ak-workspace-select" value={selectedRoom} onChange={(event) => setSelectedRoom(event.target.value)}>
                <option value="">{roomOptions.length ? scheduleCopy.allRooms : scheduleCopy.loadingRooms}</option>
                {roomOptions.map((room) => <option key={room.id} value={room.id}>{room.name}</option>)}
              </select>
            </label>

            <label className="ak-workspace-field">
              <span>{scheduleCopy.statusFilter}</span>
              <select className="ak-workspace-select" value={statusFilter} onChange={(event) => setStatusFilter(event.target.value)}>
                <option value="all">{scheduleCopy.allStatuses}</option>
                <option value="scheduled">{scheduleCopy.scheduled}</option>
                <option value="live">{scheduleCopy.live}</option>
                <option value="completed">{scheduleCopy.completed}</option>
              </select>
            </label>

            <label className="ak-workspace-field ak-workspace-field-grow">
              <span>{scheduleCopy.search}</span>
              <input
                className="ak-workspace-input"
                value={searchTerm}
                placeholder={scheduleCopy.searchPlaceholder}
                onChange={(event) => setSearchTerm(event.target.value)}
              />
            </label>

            <div className="ak-workspace-inline-actions ak-workspace-schedule-actions">
              <button
                type="button"
                className="ak-workspace-row-btn"
                onClick={() => {
                  setSelectedRoom('');
                  setStatusFilter('all');
                  setSearchTerm('');
                }}
              >
                {scheduleCopy.resetFilters}
              </button>
              <button type="button" className="ak-workspace-row-btn" onClick={() => loadAllSessions(selectedRoom)}>
                {scheduleCopy.reload}
              </button>
              <button type="button" className="ak-workspace-primary-btn" onClick={() => setShowPlannerModal(true)}>
                {scheduleCopy.openPlanner}
              </button>
              <a href="/ext/future-meetings/ics/all" className="ak-workspace-link-btn" target="_blank" rel="noreferrer">
                {scheduleCopy.globalIcs}
              </a>
              {roomIcsHref && (
                <a href={roomIcsHref} className="ak-workspace-link-btn" target="_blank" rel="noreferrer">
                  {scheduleCopy.roomIcs}
                </a>
              )}
            </div>
          </div>

          {status.message && (
            <p className={`ak-workspace-status ${status.error ? 'is-error' : ''}`}>
              {status.message}
            </p>
          )}
        </section>

        <section className="ak-workspace-metrics-grid ak-workspace-metrics-grid-tight ak-workspace-tool-grid-gap-top">
          <MetricCard
            accent="red"
            icon={CalendarDaysIcon}
            label={scheduleCopy.statsLoaded}
            value={loadingSessions ? '...' : sessionStats.total}
            helper={selectedRoom ? getRoomName(selectedRoom, roomDirectory) : scheduleCopy.allRooms}
          />
          <MetricCard
            accent="blue"
            icon={ClockIcon}
            label={scheduleCopy.statsUpcoming}
            value={loadingSessions ? '...' : sessionStats.upcoming}
            helper={sessionStats.nextUpcoming ? formatDateTime(sessionStats.nextUpcoming.startAt, language) : scheduleCopy.noNextStart}
          />
          <MetricCard
            accent="slate"
            icon={ChartBarIcon}
            label={scheduleCopy.statsLive}
            value={loadingSessions ? '...' : sessionStats.live}
            helper={scheduleCopy.live}
          />
          <MetricCard
            accent="dark"
            icon={DocumentDuplicateIcon}
            label={scheduleCopy.statsCompleted}
            value={loadingSessions ? '...' : sessionStats.completed}
            helper={scheduleCopy.tableTitle}
          />
        </section>

        <section className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top">
          <div className="ak-workspace-surface-head">
            <h2>{scheduleCopy.tableTitle}</h2>
            <span>{scheduleCopy.tableBody}</span>
          </div>

          <div className="ak-workspace-table-wrap">
            <table className="ak-workspace-table ak-workspace-schedule-table">
              <thead>
                <tr>
                  <th>{scheduleCopy.sessionCol}</th>
                  <th>{scheduleCopy.startCol}</th>
                  <th>{scheduleCopy.endCol}</th>
                  <th>{scheduleCopy.durationCol}</th>
                  <th>{scheduleCopy.sourceCol}</th>
                  <th>{scheduleCopy.participantsCol}</th>
                  <th>{scheduleCopy.statusCol}</th>
                  <th>{scheduleCopy.actionsCol}</th>
                </tr>
              </thead>
              <tbody>
                {loadingSessions && (
                  <tr><td colSpan="8">{scheduleCopy.loading}</td></tr>
                )}
                {!loadingSessions && !sessionRows.length && (
                  <tr><td colSpan="8">{scheduleCopy.noSessions}</td></tr>
                )}
                {!loadingSessions && !!sessionRows.length && !pagedMeetings.length && (
                  <tr><td colSpan="8">{scheduleCopy.noMatches}</td></tr>
                )}
                {!loadingSessions && pagedMeetings.map((meeting) => (
                  <tr key={meeting.id}>
                    <td>
                      <div className="ak-workspace-session-cell">
                        <div className="ak-workspace-table-cell-main">{meeting.title}</div>
                        <div className="ak-workspace-table-cell-sub ak-workspace-table-cell-sub-id">
                          {scheduleCopy.sessionId}: {meeting.sessionId}
                        </div>
                        <span className="ak-workspace-mini-badge">{meeting.roomName}</span>
                      </div>
                    </td>
                    <td>{formatDateTime(meeting.startAt, language)}</td>
                    <td>{formatDateTime(meeting.endAt, language)}</td>
                    <td>{meeting.durationLabel}</td>
                    <td>{meeting.sourceLabel}</td>
                    <td>{meeting.participantsLabel}</td>
                    <td>
                      <span className={`ak-workspace-badge ${meeting.sessionState.className}`}>{meeting.sessionState.label}</span>
                    </td>
                    <td>
                      <div className="ak-workspace-inline-actions ak-workspace-inline-actions-wrap ak-workspace-row-actions">
                        {meeting.canStartNow && (
                          <button
                            type="button"
                            className="ak-workspace-row-btn"
                            onClick={() => startScheduledMeetingNow(meeting)}
                          >
                            {scheduleCopy.startNow}
                          </button>
                        )}
                        {meeting.canJoin && meeting.openHref && (
                          <a href={meeting.openHref} className="ak-workspace-link-btn" target="_blank" rel="noreferrer">
                            {scheduleCopy.join}
                          </a>
                        )}
                        {meeting.canReport && (
                          <button type="button" className="ak-workspace-row-btn" onClick={() => openMeetingReport(meeting)}>
                            {scheduleCopy.viewReport}
                          </button>
                        )}
                        {meeting.canCancel && (
                          <button type="button" className="ak-workspace-row-btn" onClick={() => cancelMeeting(meeting.scheduleId)}>
                            {scheduleCopy.cancel}
                          </button>
                        )}
                        {!meeting.canStartNow && !meeting.canJoin && !meeting.canReport && !meeting.canCancel && '-'}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {!loadingSessions && (!!sessionRows.length || hasActiveFilters) && (
            <WorkspaceTableFooter
              page={safePage}
              rowsPerPage={rowsPerPage}
              totalItems={filteredMeetings.length}
              onPageChange={setTablePage}
              onRowsChange={setRowsPerPage}
              copy={scheduleCopy}
            />
          )}
        </section>
      </div>

      <BootstrapModal show={showPlannerModal} onHide={() => setShowPlannerModal(false)} centered size="lg">
        <BootstrapModal.Header closeButton>
          <BootstrapModal.Title>{scheduleCopy.plannerTitle}</BootstrapModal.Title>
        </BootstrapModal.Header>
        <BootstrapModal.Body>
          <div className="ak-workspace-tool-head">
            <p>{scheduleCopy.plannerBody}</p>
          </div>

          <form className="ak-workspace-form-grid ak-workspace-form-grid-schedule-planner" onSubmit={createMeeting}>
            <label className="ak-workspace-field">
              <span>{scheduleCopy.room}</span>
              <select className="ak-workspace-select" value={form.room} onChange={(event) => setField('room', event.target.value)}>
                <option value="">{roomOptions.length ? scheduleCopy.selectRoom : scheduleCopy.loadingRooms}</option>
                {roomOptions.map((room) => <option key={room.id} value={room.id}>{room.name}</option>)}
              </select>
            </label>

            <label className="ak-workspace-field">
              <span>{scheduleCopy.timezone}</span>
              <input className="ak-workspace-input" value={form.timezone} onChange={(event) => setField('timezone', event.target.value)} />
            </label>

            <label className="ak-workspace-field ak-workspace-field-span-2">
              <span>{scheduleCopy.titleLabel}</span>
              <input className="ak-workspace-input" value={form.title} onChange={(event) => setField('title', event.target.value)} />
            </label>

            <label className="ak-workspace-field ak-workspace-field-span-2">
              <span>{scheduleCopy.description}</span>
              <textarea className="ak-workspace-textarea" value={form.description} onChange={(event) => setField('description', event.target.value)} />
            </label>

            <label className="ak-workspace-field">
              <span>{scheduleCopy.start}</span>
              <input type="datetime-local" className="ak-workspace-input" value={form.startAt} onChange={(event) => setField('startAt', event.target.value)} />
            </label>

            <label className="ak-workspace-field">
              <span>{scheduleCopy.end}</span>
              <input type="datetime-local" className="ak-workspace-input" value={form.endAt} onChange={(event) => setField('endAt', event.target.value)} />
            </label>

            <div className="ak-workspace-inline-actions ak-workspace-field-span-2">
              <button type="submit" className="ak-workspace-primary-btn">{scheduleCopy.create}</button>
              <button type="button" className="ak-workspace-row-btn" onClick={() => setShowPlannerModal(false)}>{scheduleCopy.closePlanner}</button>
            </div>
          </form>
        </BootstrapModal.Body>
      </BootstrapModal>

      <BootstrapModal
        show={showReportModal}
        onHide={() => {
          setShowReportModal(false);
          setShowParticipantModal(false);
        }}
        centered
        size="xl"
      >
        <BootstrapModal.Header closeButton>
          <BootstrapModal.Title>{scheduleCopy.reportTitle}</BootstrapModal.Title>
        </BootstrapModal.Header>
        <BootstrapModal.Body>
          {reportStatus.message && (
            <p className={`ak-workspace-status ${reportStatus.error ? 'is-error' : ''}`}>{reportStatus.message}</p>
          )}

          {reportMeeting && (
            <div className="ak-workspace-modal-stack">
              <div className="ak-workspace-modal-summary">
                <div className="ak-workspace-table-cell-main">{reportMeeting.title}</div>
                <div className="ak-workspace-table-cell-sub">{scheduleCopy.sessionId}: {reportMeeting.sessionId}</div>
                <span className="ak-workspace-mini-badge">{reportMeeting.roomName}</span>
              </div>

              <div className="ak-workspace-metrics-grid ak-workspace-metrics-grid-tight">
                <MetricCard accent="red" icon={IdentificationIcon} label={scheduleCopy.reportParticipants} value={reportLoading ? '...' : reportMetrics.participants} helper={formatDateOnly(reportMeeting.startAt, language)} />
                <MetricCard accent="blue" icon={ChartBarIcon} label={scheduleCopy.reportAttendance} value={reportLoading ? '...' : `${reportMetrics.attendanceScore}%`} helper={scheduleCopy.completed} />
                <MetricCard accent="slate" icon={ClockIcon} label={scheduleCopy.reportActivity} value={reportLoading ? '...' : `${reportMetrics.activityScore}%`} helper={scheduleCopy.sourceMeeting} />
                <MetricCard accent="dark" icon={DocumentDuplicateIcon} label={scheduleCopy.reportEvents} value={reportLoading ? '...' : reportMetrics.events} helper={scheduleCopy.reportExports} />
              </div>

              <div className="ak-workspace-inline-actions">
                <button
                  type="button"
                  className="ak-workspace-link-btn"
                  onClick={() => downloadParticipantsExcel({
                    rows: reportParticipantRows,
                    meetingName: reportMeeting.title,
                    filePrefix: 'workspace-session-report',
                    language,
                  })}
                  disabled={!reportParticipantRows.length}
                >
                  {scheduleCopy.exportExcel}
                </button>
                {reportCsvHref && <a href={reportCsvHref} className="ak-workspace-link-btn" target="_blank" rel="noreferrer">{scheduleCopy.exportCsv}</a>}
                {reportJsonHref && <a href={reportJsonHref} className="ak-workspace-link-btn" target="_blank" rel="noreferrer">{scheduleCopy.exportJson}</a>}
              </div>

              <div className="ak-workspace-tool-card ak-workspace-tool-card-tight">
                <div className="ak-workspace-surface-head">
                  <h2>{scheduleCopy.reportParticipants}</h2>
                  <span>{reportLoading ? scheduleCopy.reportLoading : `${reportParticipantRows.length} ${scheduleCopy.reportParticipants.toLowerCase()}`}</span>
                </div>

                <div className="ak-workspace-table-wrap">
                  <table className="ak-workspace-table">
                    <thead>
                      <tr>
                        <th>{copy.recordingsDetail.user}</th>
                        <th>{copy.recordingsDetail.role}</th>
                        <th>{scheduleCopy.statusLabel}</th>
                        <th>{scheduleCopy.start}</th>
                        <th>{scheduleCopy.end}</th>
                        <th>{scheduleCopy.onlineTime}</th>
                        <th>{scheduleCopy.reportAttendance}</th>
                        <th>{scheduleCopy.attentionScore}</th>
                        <th>{scheduleCopy.engagementScore}</th>
                        <th>{scheduleCopy.activityMetric}</th>
                        <th>{scheduleCopy.actionsCol}</th>
                      </tr>
                    </thead>
                    <tbody>
                      {reportLoading && <tr><td colSpan="11">{scheduleCopy.reportLoading}</td></tr>}
                      {!reportLoading && !reportParticipantRows.length && <tr><td colSpan="11">{scheduleCopy.reportEmpty}</td></tr>}
                      {!reportLoading && reportParticipantRows.map((user) => (
                        <tr key={user.key}>
                          <td>
                            <div className="ak-workspace-table-cell-main">{user.user}</div>
                            <div className="ak-workspace-table-cell-sub ak-workspace-table-cell-sub-id">{user.userId}</div>
                          </td>
                          <td>{user.role}</td>
                          <td><span className={`ak-room-badge ${user.statusClass}`}>{user.statusLabel}</span></td>
                          <td>{formatDateTime(user.firstJoinAt, language)}</td>
                          <td>{formatDateTime(user.lastLeaveAt, language)}</td>
                          <td>{formatDuration(user.onlineSeconds, language)}</td>
                          <td>{`${user.attendanceScore}%`}</td>
                          <td>{`${user.attentionScore}%`}</td>
                          <td>{`${user.engagementScore}%`}</td>
                          <td>{`${user.activityScore}%`}</td>
                          <td>
                            <button
                              type="button"
                              className="ak-workspace-row-btn"
                              onClick={() => {
                                setSelectedParticipantKey(user.key);
                                setShowParticipantModal(true);
                              }}
                            >
                              {scheduleCopy.detailAction}
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}
        </BootstrapModal.Body>
      </BootstrapModal>

      <BootstrapModal show={showParticipantModal} onHide={() => setShowParticipantModal(false)} centered size="lg" dialogClassName="ak-room-report-modal">
        <BootstrapModal.Header closeButton>
          <BootstrapModal.Title>{scheduleCopy.participantDetailTitle}</BootstrapModal.Title>
        </BootstrapModal.Header>
        <BootstrapModal.Body>
          {!selectedParticipantRow && <p className="text-muted mb-0">{scheduleCopy.reportEmpty}</p>}
          {!!selectedParticipantRow && (
            <>
              <section className="ak-room-participant-hero">
                <div className="ak-room-participant-hero-top">
                  <div>
                    <div className="ak-room-participant-eyebrow">{selectedParticipantRow.role || copy.recordingsDetail.user}</div>
                    <h3>{selectedParticipantRow.user}</h3>
                    <p>{scheduleCopy.participantDetailSubtitle}</p>
                  </div>
                  <span className={`ak-room-badge ${selectedParticipantRow.statusClass}`}>{selectedParticipantRow.statusLabel}</span>
                </div>
                <div className="ak-room-participant-pill-row">
                  <span className="ak-room-report-meta">{copy.recordingsDetail.user}: {selectedParticipantRow.userId || '-'}</span>
                </div>
              </section>

              <div className="ak-room-badge-row ak-room-participant-score-badges">
                <span className={`ak-room-badge ${scoreBadgeClass(selectedParticipantRow.attendanceScore)}`}>
                  {scheduleCopy.reportAttendance}: {selectedParticipantRow.attendanceScore}%
                </span>
                <span className={`ak-room-badge ${scoreBadgeClass(selectedParticipantRow.attentionScore)}`}>
                  {scheduleCopy.attentionScore}: {selectedParticipantRow.attentionScore}%
                </span>
                <span className={`ak-room-badge ${scoreBadgeClass(selectedParticipantRow.engagementScore)}`}>
                  {scheduleCopy.engagementScore}: {selectedParticipantRow.engagementScore}%
                </span>
                <span className={`ak-room-badge ${scoreBadgeClass(selectedParticipantRow.activityScore)}`}>
                  {scheduleCopy.activityMetric}: {selectedParticipantRow.activityScore}%
                </span>
                <span className={`ak-room-badge ${selectedParticipantRow.statusClass}`}>
                  {scheduleCopy.statusLabel}: {selectedParticipantRow.statusLabel}
                </span>
              </div>

              <div className="ak-room-subtabs ak-room-participant-detail-tabs" role="tablist" aria-label={scheduleCopy.participantDetailTitle}>
                {participantDetailTabs.map((tab) => (
                  <button
                    key={tab.key}
                    type="button"
                    className={`ak-room-subtab ${participantDetailTab === tab.key ? 'is-active' : ''}`}
                    onClick={() => setParticipantDetailTab(tab.key)}
                  >
                    {tab.label}
                  </button>
                ))}
              </div>

              <section className="ak-room-surface">
                <div className="ak-room-surface-head">
                  <h3>{activeParticipantDetailTab.label}</h3>
                  <span className="ak-room-report-meta">{activeParticipantDetailTab.meta}</span>
                </div>
                <AttributeTable rows={activeParticipantDetailTab.rows} copy={scheduleCopy} />
              </section>
            </>
          )}
        </BootstrapModal.Body>
      </BootstrapModal>
    </>
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
        const meetings = normalizeObjectList(data.meetings);
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
          timeline: normalizeObjectList(timeline.events),
          attention: normalizeObjectList(attention.users),
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

function AdminAccessFallback() {
  return (
    <p className="ak-workspace-status is-error">
      Access not available for this section.
    </p>
  );
}

function EmbeddedManageUsersSection({ adminCopy }) {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const [searchInput, setSearchInput] = useState('');
  const { data: registrationMethod } = useSiteSetting('RegistrationMethod');
  const envAPI = useEnv();

  return (
    <section className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top">
      <div className="ak-workspace-tool-head">
        <h3>{adminCopy.manageUsersTab}</h3>
        <p>{adminCopy.manageUsersBody}</p>
      </div>

      {!PermissionChecker.hasManageUsers(currentUser) ? (
        <AdminAccessFallback />
      ) : (
        <div className="ak-workspace-admin-embed">
          <div className="ak-workspace-admin-toolbar">
            <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
            {registrationMethod === 'invite' && (
              <InlineModal
                modalButton={(
                  <button type="button" className="ak-workspace-link-btn">
                    <EnvelopeIcon className="hi-s me-1" />
                    {t('admin.manage_users.invite_user')}
                  </button>
                )}
                title={t('admin.manage_users.invite_user')}
                body={<InviteUserForm />}
                size="md"
              />
            )}
            {!envAPI.isLoading && !envAPI.data?.EXTERNAL_AUTH && (
              <InlineModal
                modalButton={(
                  <button type="button" className="ak-workspace-primary-btn">
                    <UserPlusIcon className="hi-s me-1" />
                    {t('admin.manage_users.add_new_user')}
                  </button>
                )}
                title={t('admin.manage_users.create_new_user')}
                body={<UserSignupForm />}
              />
            )}
          </div>

          <Tabs className="ak-workspace-admin-subtabs" defaultActiveKey="active" unmountOnExit>
            <Tab eventKey="active" title={t('admin.manage_users.active')}>
              <div className="ak-workspace-admin-subtab-pane">
                <VerifiedUsers searchInput={searchInput} />
              </div>
            </Tab>
            {!envAPI.isLoading && !envAPI.data?.EXTERNAL_AUTH && (
              <Tab eventKey="unverified" title={t('admin.manage_users.unverified')}>
                <div className="ak-workspace-admin-subtab-pane">
                  <UnverifiedUsers searchInput={searchInput} />
                </div>
              </Tab>
            )}
            {registrationMethod === 'approval' && (
              <Tab eventKey="pending" title={t('admin.manage_users.pending')}>
                <div className="ak-workspace-admin-subtab-pane">
                  <PendingUsers searchInput={searchInput} />
                </div>
              </Tab>
            )}
            <Tab eventKey="banned" title={t('admin.manage_users.banned')}>
              <div className="ak-workspace-admin-subtab-pane">
                <BannedUsers searchInput={searchInput} />
              </div>
            </Tab>
            {registrationMethod === 'invite' && (
              <Tab eventKey="invited" title={t('admin.manage_users.invited_tab')}>
                <div className="ak-workspace-admin-subtab-pane">
                  <InvitedUsersTable input={searchInput} />
                </div>
              </Tab>
            )}
          </Tabs>
        </div>
      )}
    </section>
  );
}

function EmbeddedServerRoomsSection({ adminCopy }) {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const canManageRooms = PermissionChecker.hasManageRooms(currentUser);
  const [searchInput, setSearchInput] = useState('');
  const [page, setPage] = useState();
  const { isLoading, data: serverRooms } = useServerRooms(searchInput, page, canManageRooms);
  const roomCount = serverRooms?.data?.length || 0;

  return (
    <section className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top">
      <div className="ak-workspace-tool-head">
        <h3>{adminCopy.serverRoomsTab}</h3>
        <p>{adminCopy.serverRoomsBody}</p>
      </div>

      {!canManageRooms ? (
        <AdminAccessFallback />
      ) : (
        <div className="ak-workspace-admin-embed">
          <div className="ak-workspace-admin-toolbar">
            <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
          </div>

          {!isLoading && !searchInput && roomCount === 0 ? (
            <div className="ak-workspace-admin-empty">
              <EmptyServerRoomsList />
            </div>
          ) : (
            <>
              {!isLoading && !!searchInput && roomCount === 0 ? (
                <div className="ak-workspace-admin-empty">
                  <NoSearchResults text={t('room.search_not_found')} searchInput={searchInput} />
                </div>
              ) : (
                <div className="ak-workspace-admin-table-wrap">
                  <table id="server-rooms-table" className="table table-bordered border border-2 mb-0 table-hover">
                    <thead>
                      <tr className="text-muted small">
                        <th className="fw-normal border-end-0">
                          {t('admin.server_rooms.name')}
                          <SortBy fieldName="name" />
                        </th>
                        <th className="fw-normal border-0">
                          {t('admin.server_rooms.owner')}
                          <SortBy fieldName="users.name" />
                        </th>
                        <th className="fw-normal border-0">{t('admin.server_rooms.room_id')}</th>
                        <th className="fw-normal border-0">{t('admin.server_rooms.participants')}</th>
                        <th className="fw-normal border-0">{t('admin.server_rooms.status')}</th>
                        <th className="border-start-0" aria-label="options" />
                      </tr>
                    </thead>
                    <tbody className="border-top-0">
                      {isLoading
                        ? [...Array(10)].map((_, idx) => <ServerRoomsRowPlaceHolder key={idx} />)
                        : serverRooms?.data?.map((room) => <ServerRoomRow key={room.friendly_id} room={room} />)}
                    </tbody>
                    {serverRooms?.meta?.pages > 1 && (
                      <tfoot>
                        <tr>
                          <td colSpan={6}>
                            <Pagination
                              page={serverRooms?.meta?.page}
                              totalPages={serverRooms?.meta?.pages}
                              setPage={setPage}
                            />
                          </td>
                        </tr>
                      </tfoot>
                    )}
                  </table>
                </div>
              )}
            </>
          )}
        </div>
      )}
    </section>
  );
}

function EmbeddedSiteSettingsSection({ adminCopy }) {
  const { t } = useTranslation();
  const currentUser = useAuth();

  return (
    <section className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top">
      <div className="ak-workspace-tool-head">
        <h3>{adminCopy.siteSettingsTab}</h3>
        <p>{adminCopy.siteSettingsBody}</p>
      </div>

      {!PermissionChecker.hasManageSiteSettings(currentUser) ? (
        <AdminAccessFallback />
      ) : (
        <div className="ak-workspace-admin-embed">
          <Tabs className="ak-workspace-admin-subtabs" defaultActiveKey="appearance" unmountOnExit>
            <Tab eventKey="appearance" title={t('admin.site_settings.appearance.appearance')}>
              <div className="ak-workspace-admin-subtab-pane">
                <Appearance />
              </div>
            </Tab>
            <Tab eventKey="administration" title={t('admin.site_settings.administration.administration')}>
              <div className="ak-workspace-admin-subtab-pane">
                <Administration />
              </div>
            </Tab>
            <Tab eventKey="settings" title={t('admin.site_settings.settings.settings')}>
              <div className="ak-workspace-admin-subtab-pane">
                <Settings />
              </div>
            </Tab>
            <Tab eventKey="registration" title={t('admin.site_settings.registration.registration')}>
              <div className="ak-workspace-admin-subtab-pane">
                <Registration />
              </div>
            </Tab>
          </Tabs>
        </div>
      )}
    </section>
  );
}

function EmbeddedRolesSection({ adminCopy }) {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const canManageRoles = PermissionChecker.hasManageRoles(currentUser);
  const [searchInput, setSearchInput] = useState('');
  const { data: roles, isLoading } = useRoles({ search: searchInput, enabled: canManageRoles });

  return (
    <section className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top">
      <div className="ak-workspace-tool-head">
        <h3>{adminCopy.rolesTab}</h3>
        <p>{adminCopy.rolesBody}</p>
      </div>

      {!canManageRoles ? (
        <AdminAccessFallback />
      ) : (
        <div className="ak-workspace-admin-embed">
          <div className="ak-workspace-admin-toolbar">
            <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
            <CreateRoleModal />
          </div>

          {!!searchInput && roles?.length === 0 ? (
            <div className="ak-workspace-admin-empty">
              <NoSearchResults text={t('admin.roles.search_not_found')} searchInput={searchInput} />
            </div>
          ) : (
            <RolesList isLoading={isLoading} roles={roles} />
          )}
        </div>
      )}
    </section>
  );
}

function AdminWorkspace({ copy, language, actorName }) {
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
  const [activeAdminTab, setActiveAdminTab] = useState('users');
  const [auditPage, setAuditPage] = useState(1);
  const [auditRowsPerPage, setAuditRowsPerPage] = useState(10);

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
      const logs = normalizeObjectList(data.logs);
      setAuditLogs(logs);
      setAuditPage(1);
      setStatus({ message: `${logs.length} audit log(s) loaded.`, error: false });
    } catch (err) {
      setAuditLogs([]);
      setAuditPage(1);
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
  const totalAuditPages = Math.max(Math.ceil(totalLogs / auditRowsPerPage), 1);
  const currentAuditPage = Math.min(auditPage, totalAuditPages);
  const paginatedAuditLogs = useMemo(() => {
    const startIndex = (currentAuditPage - 1) * auditRowsPerPage;
    return auditLogs.slice(startIndex, startIndex + auditRowsPerPage);
  }, [auditLogs, auditRowsPerPage, currentAuditPage]);
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

  const handleAuditRowsChange = (value) => {
    setAuditRowsPerPage(value);
    setAuditPage(1);
  };

  const adminTabs = [
    { key: 'users', label: adminCopy.manageUsersTab, icon: UserGroupIcon },
    { key: 'serverRooms', label: adminCopy.serverRoomsTab, icon: Square2StackIcon },
    { key: 'roomConfig', label: adminCopy.roomConfigTab, icon: AdjustmentsHorizontalIcon },
    { key: 'siteSettings', label: adminCopy.siteSettingsTab, icon: Cog6ToothIcon },
    { key: 'roles', label: adminCopy.rolesTab, icon: ShieldCheckIcon },
    { key: 'audit', label: adminCopy.auditLogsTab, icon: ClipboardDocumentListIcon },
  ];

  const adminOverviewBadges = [
    { label: copy.adminWidgets.rooms, value: roomsLoading ? '...' : rooms.length, className: 'is-neutral' },
    { label: copy.adminWidgets.logs, value: loadingAudit ? '...' : totalLogs, className: 'is-ok' },
    { label: copy.adminWidgets.actors, value: loadingAudit ? '...' : uniqueActors, className: 'is-neutral' },
    { label: copy.adminWidgets.exports, value: loadingAudit ? '...' : exportLogs, className: 'is-warn' },
    { label: copy.adminWidgets.schedule, value: loadingAudit ? '...' : scheduleLogs, className: 'is-warn' },
    { label: copy.adminWidgets.sections, value: adminTabs.length, className: 'is-bad' },
  ];

  return (
    <div className="ak-workspace-panel">
      <PanelIntro eyebrow={copy.tabs.admin} title={copy.adminPanel.title} body={copy.adminPanel.body} />

      <section className="ak-workspace-tool-card ak-workspace-tool-card-tight">
        <div className="ak-workspace-tool-head">
          <h3>{adminCopy.overviewTitle}</h3>
        </div>
        <div className="ak-workspace-badge-row ak-workspace-admin-badge-row">
          {adminOverviewBadges.map((item) => (
            <span key={item.label} className={`ak-workspace-badge ${item.className} ak-workspace-admin-stat-badge`}>
              <strong>{item.value}</strong>
              <span>{item.label}</span>
            </span>
          ))}
        </div>
      </section>

      <div className="ak-room-tabs ak-workspace-admin-tabs" role="tablist" aria-label="Admin workspace tabs">
        {adminTabs.map((tab) => {
          const active = tab.key === activeAdminTab;
          const Icon = tab.icon;

          return (
            <button
              key={tab.key}
              type="button"
              role="tab"
              aria-selected={active}
              className={`ak-room-tab ${active ? 'is-active' : ''}`}
              onClick={() => setActiveAdminTab(tab.key)}
            >
              <Icon className="ak-room-tab-icon" aria-hidden="true" />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>

      {activeAdminTab === 'users' && <EmbeddedManageUsersSection adminCopy={adminCopy} />}

      {activeAdminTab === 'serverRooms' && <EmbeddedServerRoomsSection adminCopy={adminCopy} />}

      {activeAdminTab === 'roomConfig' && (
        <div className="ak-workspace-tool-grid ak-workspace-tool-grid-2 ak-workspace-tool-grid-gap-top">
          <section className="ak-workspace-tool-card">
            <div className="ak-workspace-tool-head">
              <h3>{adminCopy.roomRules}</h3>
              <p>{adminCopy.roomConfigBody}</p>
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
      )}

      {activeAdminTab === 'siteSettings' && <EmbeddedSiteSettingsSection adminCopy={adminCopy} />}

      {activeAdminTab === 'roles' && <EmbeddedRolesSection adminCopy={adminCopy} />}

      {activeAdminTab === 'audit' && (
        <section className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top">
          <div className="ak-workspace-tool-head">
            <h3>{adminCopy.auditLogsTab}</h3>
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
                {paginatedAuditLogs.map((log) => (
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

          {!loadingAudit && totalLogs > 0 && (
            <WorkspaceTableFooter
              page={currentAuditPage}
              rowsPerPage={auditRowsPerPage}
              totalItems={totalLogs}
              onPageChange={setAuditPage}
              onRowsChange={handleAuditRowsChange}
              copy={copy.schedulePanel}
              pageSizes={[5, 10, 15, 20, 25, 50]}
            />
          )}
        </section>
      )}
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

function OverviewInsights({ copy, language, roomDirectory }) {
  const { rooms, loading: roomsLoading, error: roomsError } = useExtRooms();
  const [recentMeetings, setRecentMeetings] = useState([]);
  const [loadingMeetings, setLoadingMeetings] = useState(true);
  const scopedRooms = useMemo(() => {
    const accessibleMeetingIds = new Set(roomDirectory ? Array.from(roomDirectory.keys()) : []);

    if (!accessibleMeetingIds.size) {
      return [];
    }

    return rooms.filter((room) => accessibleMeetingIds.has(room.id));
  }, [roomDirectory, rooms]);

  useEffect(() => {
    let active = true;

    const loadMeetings = async () => {
      setLoadingMeetings(true);
      try {
        const data = await fetchExtJson('/ext/recent-meetings?limit=500&includeEnded=1');
        if (!active) return;
        setRecentMeetings(data.meetings || []);
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

  const topRooms = [...scopedRooms]
    .sort((a, b) => (b.sessionsCount || 0) - (a.sessionsCount || 0))
    .slice(0, 4);

  const trendMeetings = useMemo(
    () => [...recentMeetings].slice(0, 8).reverse(),
    [recentMeetings],
  );
  const roomParticipantsTotals = useMemo(() => {
    const totals = new Map();

    recentMeetings.forEach((meeting) => {
      const roomId = `${meeting?.meeting_ext_id || ''}`;
      if (!roomId) return;
      totals.set(roomId, (totals.get(roomId) || 0) + safeNumber(meeting.participants_count));
    });

    return totals;
  }, [recentMeetings]);
  const maxMeetingUsers = trendMeetings.reduce((max, meeting) => Math.max(max, meeting.participants_count || 0), 1);
  const maxRoomSessions = topRooms.reduce((max, room) => Math.max(max, room.sessionsCount || 0), 1);

  return (
    <section className="ak-workspace-tool-grid ak-workspace-tool-grid-2 ak-workspace-tool-grid-gap-bottom">
      <section className="ak-workspace-tool-card">
        <div className="ak-workspace-tool-head">
          <h3>{copy.insights.trend}</h3>
        </div>

        {loadingMeetings && <p className="ak-workspace-status">Loading...</p>}
        {!loadingMeetings && !trendMeetings.length && <p className="ak-workspace-status">{copy.insights.noTrend}</p>}

        {!loadingMeetings && trendMeetings.length > 0 && (
          <div className="ak-workspace-trend-chart">
            {trendMeetings.map((meeting) => {
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
            {topRooms.map((room) => {
              const participantsTotal = roomParticipantsTotals.get(room.id) || 0;

              return (
                <div key={room.id} className="ak-workspace-ranked-row">
                  <div className="ak-workspace-ranked-copy">
                    <strong>{getRoomName(room.id, roomDirectory)}</strong>
                    <div className="ak-workspace-badge-row">
                      <div className="ak-workspace-badge is-neutral">{room.sessionsCount || 0} {copy.insights.sessions}</div>
                      <div className="ak-workspace-badge is-ok">{participantsTotal} {copy.insights.participants}</div>
                    </div>
                  </div>
                  <div className="ak-workspace-ranked-track">
                    <span
                      className="ak-workspace-ranked-fill"
                      style={{ width: `${Math.max(Math.round(((room.sessionsCount || 0) / maxRoomSessions) * 100), room.sessionsCount ? 10 : 0)}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </section>
    </section>
  );
}

function RecordingsWorkspace({
  copy, language, availableRooms, roomDirectory, recordingsCount,
}) {
  const recordingsCopy = copy.recordingsPanel;
  const roomOptions = useMemo(() => buildRoomOptions(availableRooms, roomDirectory, 'friendly'), [availableRooms, roomDirectory]);
  const [page, setPage] = useState(1);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [roomFilter, setRoomFilter] = useState('');
  const [visibilityFilter, setVisibilityFilter] = useState('');
  const { isLoading, data: recordings } = useRecordings(searchTerm, page, rowsPerPage, {
    room: roomFilter,
    visibility: visibilityFilter,
  });

  useEffect(() => {
    setPage(1);
  }, [rowsPerPage, roomFilter, searchTerm, visibilityFilter]);

  const rows = recordings?.data || [];
  const totalItems = recordings?.meta?.count ?? (recordingsCount ?? rows.length);
  const totalFormats = rows.reduce((sum, recording) => sum + (Array.isArray(recording.formats) ? recording.formats.length : 0), 0);
  const totalParticipants = rows.reduce((sum, recording) => sum + safeNumber(recording.participants), 0);
  const currentPage = recordings?.meta?.page || page;
  const visibilityOptions = ['Published', 'Unpublished', 'Protected', 'Public', 'Public/Protected'];

  return (
    <div className="ak-workspace-panel ak-workspace-recordings">
      <PanelIntro eyebrow={copy.tabs.recordings} title={recordingsCopy.title} body={recordingsCopy.body} />

      <section className="ak-workspace-tool-card ak-workspace-tool-card-tight">
        <div className="ak-workspace-tool-head">
          <h3>{recordingsCopy.filtersTitle}</h3>
        </div>

        <div className="ak-workspace-form-grid ak-workspace-form-grid-recordings">
          <label className="ak-workspace-field">
            <span>{recordingsCopy.room}</span>
            <select className="ak-workspace-select" value={roomFilter} onChange={(event) => setRoomFilter(event.target.value)}>
              <option value="">{recordingsCopy.allRooms}</option>
              {roomOptions.map((room) => <option key={room.id} value={room.id}>{room.name}</option>)}
            </select>
          </label>

          <label className="ak-workspace-field">
            <span>{recordingsCopy.visibility}</span>
            <select className="ak-workspace-select" value={visibilityFilter} onChange={(event) => setVisibilityFilter(event.target.value)}>
              <option value="">{recordingsCopy.allVisibility}</option>
              {visibilityOptions.map((option) => <option key={option} value={option}>{option}</option>)}
            </select>
          </label>

          <label className="ak-workspace-field ak-workspace-field-grow">
            <span>{recordingsCopy.search}</span>
            <input
              className="ak-workspace-input"
              value={searchTerm}
              placeholder={recordingsCopy.searchPlaceholder}
              onChange={(event) => setSearchTerm(event.target.value)}
            />
          </label>

          <div className="ak-workspace-inline-actions ak-workspace-schedule-actions">
            <button
              type="button"
              className="ak-workspace-row-btn"
              onClick={() => {
                setRoomFilter('');
                setVisibilityFilter('');
                setSearchTerm('');
              }}
            >
              {recordingsCopy.resetFilters}
            </button>
          </div>
        </div>
      </section>

      <section className="ak-workspace-metrics-grid ak-workspace-metrics-grid-tight ak-workspace-tool-grid-gap-top">
        <MetricCard
          accent="red"
          icon={VideoCameraIcon}
          label={recordingsCopy.statsTotal}
          value={recordingsCount ?? '...'}
          helper={recordingsCopy.tableTitle}
        />
        <MetricCard
          accent="blue"
          icon={DocumentDuplicateIcon}
          label={recordingsCopy.statsFiltered}
          value={isLoading ? '...' : totalItems}
          helper={roomFilter ? getRoomName(roomFilter, roomDirectory) : recordingsCopy.allRooms}
        />
        <MetricCard
          accent="slate"
          icon={IdentificationIcon}
          label={recordingsCopy.statsParticipants}
          value={isLoading ? '...' : totalParticipants}
          helper={`${rows.length} rows`}
        />
        <MetricCard
          accent="dark"
          icon={ChartBarIcon}
          label={recordingsCopy.statsFormats}
          value={isLoading ? '...' : totalFormats}
          helper={visibilityFilter || recordingsCopy.allVisibility}
        />
      </section>

      <section className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top">
        <div className="ak-workspace-surface-head">
          <h2>{recordingsCopy.tableTitle}</h2>
          <span>{recordingsCopy.tableBody}</span>
        </div>

        <div className="ak-workspace-table-wrap">
          <table className="ak-workspace-table">
            <thead>
              <tr>
                <th>{recordingsCopy.recordingCol}</th>
                <th>{recordingsCopy.roomCol}</th>
                <th>{recordingsCopy.recordedCol}</th>
                <th>{recordingsCopy.durationCol}</th>
                <th>{recordingsCopy.participantsCol}</th>
                <th>{recordingsCopy.visibilityCol}</th>
                <th>{recordingsCopy.formatsCol}</th>
                <th>{recordingsCopy.actionsCol}</th>
              </tr>
            </thead>
            <tbody>
              {isLoading && <tr><td colSpan="8">{recordingsCopy.loading}</td></tr>}
              {!isLoading && !rows.length && <tr><td colSpan="8">{recordingsCopy.noMatches}</td></tr>}
              {!isLoading && rows.map((recording) => {
                const openHref = getPreferredRecordingUrl(recording);

                return (
                  <tr key={recording.id}>
                    <td>
                      <div className="ak-workspace-session-cell">
                        <div className="ak-workspace-table-cell-main">{recording.name}</div>
                        <div className="ak-workspace-table-cell-sub ak-workspace-table-cell-sub-id">{recording.record_id}</div>
                      </div>
                    </td>
                    <td>
                      <div className="ak-workspace-table-cell-main">{recording.room_name || getRoomName(recording.room_friendly_id, roomDirectory)}</div>
                      <div className="ak-workspace-table-cell-sub ak-workspace-table-cell-sub-id">{recording.room_friendly_id || '-'}</div>
                    </td>
                    <td>{formatDateTime(recording.recorded_at || recording.created_at, language)}</td>
                    <td>{formatDuration(recording.length, language)}</td>
                    <td>{safeNumber(recording.participants)}</td>
                    <td>{recording.visibility || '-'}</td>
                    <td>
                      <div className="ak-workspace-format-list">
                        {(recording.formats || []).map((format) => (
                          <span key={`${recording.id}-${format.recording_type}`} className="ak-workspace-format-pill">
                            {format.recording_type}
                          </span>
                        ))}
                        {!recording.formats?.length && '-'}
                      </div>
                    </td>
                    <td>
                      {openHref ? (
                        <a href={openHref} className="ak-workspace-link-btn" target="_blank" rel="noreferrer">
                          {recordingsCopy.open}
                        </a>
                      ) : '-'}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {!isLoading && (!!rows.length || !!searchTerm || !!roomFilter || !!visibilityFilter) && (
          <WorkspaceTableFooter
            page={currentPage}
            rowsPerPage={rowsPerPage}
            totalItems={totalItems}
            onPageChange={setPage}
            onRowsChange={setRowsPerPage}
            copy={copy.schedulePanel}
          />
        )}
      </section>
    </div>
  );
}

export default function Rooms({ forcedView = null, hideTabs = false, embedded = false }) {
  const currentUser = useAuth();
  const { i18n } = useTranslation();
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const { data: recordingsCount } = useRecordingsCount();
  const { data: recordValue } = useRoomConfigValue('record');
  const { data: rooms = [], isLoading: roomsLoading } = useRooms('');
  const roomDirectoryByFriendlyId = useMemo(() => {
    const next = new Map();
    rooms.forEach((room) => {
      if (room?.friendly_id) {
        next.set(room.friendly_id, room);
      }
    });
    return next;
  }, [rooms]);
  const roomDirectoryByMeetingId = useMemo(() => {
    const next = new Map();
    rooms.forEach((room) => {
      if (room?.meeting_id) {
        next.set(room.meeting_id, room);
      }
    });
    return next;
  }, [rooms]);

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
        analytics: '/reports',
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
          <RecordingsWorkspace
            copy={copy}
            language={language}
            availableRooms={rooms}
            roomDirectory={roomDirectoryByFriendlyId}
            recordingsCount={recordingsCount}
          />
        );
      case 'schedule':
        return (
          <ScheduleWorkspace
            copy={copy}
            language={language}
            actorName={currentUser?.name || 'ops-admin'}
            availableRooms={rooms}
            roomDirectory={roomDirectoryByMeetingId}
          />
        );
      case 'analytics':
        return (
          <AnalyticsWorkspace copy={copy} language={language} />
        );
      case 'admin':
        return (
          <AdminWorkspace copy={copy} language={language} actorName={currentUser?.name || 'ops-admin'} />
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

            <OverviewInsights copy={copy} language={language} roomDirectory={roomDirectoryByMeetingId} />

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

  const content = (
    <>
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
    </>
  );

  if (embedded) {
    return content;
  }

  return (
    <div className="ak-workspace">
      <div className="ak-workspace-shell">
        {content}
      </div>
    </div>
  );
}
