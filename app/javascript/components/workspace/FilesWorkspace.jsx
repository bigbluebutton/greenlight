import React, {
  useEffect,
  useMemo,
  useState,
} from 'react';
import {
  FolderIcon,
  LinkIcon,
} from '@heroicons/react/24/outline';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useRooms from '../../hooks/queries/rooms/useRooms';
import Presentation from '../rooms/room/presentation/Presentation';

const FILES_MODULE_COPY = {
  en: {
    eyebrow: 'Files',
    title: 'Session and Room Files',
    body: 'Manage your presentation library, shared templates, and room defaults from one place.',
    roomScope: 'File scope',
    roomScopeBody: 'Choose a room to manage uploads and defaults. Changes apply to the selected room immediately.',
    room: 'Room',
    selectRoom: 'Select room',
    loadingRooms: 'Loading rooms...',
    owner: 'Owner',
    roomType: 'Type',
    ownedRoom: 'Owned room',
    sharedRoom: 'Shared room',
    openRoom: 'Open room detail',
    noRooms: 'No rooms are available for file management.',
    sharedOwner: 'Shared owner',
  },
  tr: {
    eyebrow: 'Dosyalar',
    title: 'Oturum ve Oda Dosyalari',
    body: 'Sunum kutuphanenizi, paylasilan sablonlari ve oda varsayilanlarini tek bir yerden yonetin.',
    roomScope: 'Dosya kapsami',
    roomScopeBody: 'Yukleme ve varsayilan yonetimi icin bir oda secin. Degisiklikler secilen odaya aninda uygulanir.',
    room: 'Oda',
    selectRoom: 'Oda secin',
    loadingRooms: 'Odalar yukleniyor...',
    owner: 'Sahip',
    roomType: 'Tur',
    ownedRoom: 'Sahip olunan oda',
    sharedRoom: 'Paylasilan oda',
    openRoom: 'Oda detayini ac',
    noRooms: 'Dosya yonetimi icin kullanilabilir oda yok.',
    sharedOwner: 'Paylasim sahibi',
  },
};

function normalizeRoomOptions(rooms = [], currentUserName = '') {
  return rooms
    .map((room) => {
      const friendlyId = room?.friendly_id || room?.id || '';
      if (!friendlyId) return null;
      const sharedOwner = room?.shared_owner || '';
      const shared = !!sharedOwner;
      const ownerName = shared
        ? sharedOwner
        : (room?.owner_name || room?.owner || currentUserName || '-');

      return {
        id: friendlyId,
        name: room?.name || friendlyId,
        ownerName,
        shared,
      };
    })
    .filter(Boolean)
    .sort((left, right) => left.name.localeCompare(right.name));
}

export default function FilesWorkspace() {
  const currentUser = useAuth();
  const language = currentUser?.language === 'tr' ? 'tr' : 'en';
  const copy = FILES_MODULE_COPY[language];
  const { data: rooms = [], isLoading: roomsLoading } = useRooms('');

  const roomOptions = useMemo(
    () => normalizeRoomOptions(rooms, currentUser?.name || ''),
    [rooms, currentUser?.name],
  );
  const [selectedRoom, setSelectedRoom] = useState('');

  useEffect(() => {
    if (!roomOptions.length) {
      if (selectedRoom) setSelectedRoom('');
      return;
    }

    if (!selectedRoom || !roomOptions.some((room) => room.id === selectedRoom)) {
      setSelectedRoom(roomOptions[0].id);
    }
  }, [roomOptions, selectedRoom]);

  const selectedRoomData = useMemo(
    () => roomOptions.find((room) => room.id === selectedRoom) || null,
    [roomOptions, selectedRoom],
  );

  return (
    <div className="ak-workspace">
      <div className="ak-workspace-shell">
        <section className="ak-module-shell">
          <div className="ak-module-hero">
            <span className="ak-module-eyebrow">{copy.eyebrow}</span>
            <h1>{copy.title}</h1>
            <p>{copy.body}</p>
          </div>
        </section>

        <section className="ak-workspace-panel ak-workspace-files-panel">
          <div className="ak-workspace-tool-card ak-workspace-tool-card-tight">
            <div className="ak-workspace-tool-head">
              <h3>{copy.roomScope}</h3>
              <p>{copy.roomScopeBody}</p>
            </div>
            <div className="ak-workspace-form-grid ak-workspace-form-grid-recordings">
              <label className="ak-workspace-field ak-workspace-field-grow">
                <span>{copy.room}</span>
                <select
                  className="ak-workspace-select"
                  value={selectedRoom}
                  onChange={(event) => setSelectedRoom(event.target.value)}
                  disabled={roomsLoading || !roomOptions.length}
                >
                  <option value="">
                    {roomsLoading ? copy.loadingRooms : copy.selectRoom}
                  </option>
                  {roomOptions.map((room) => (
                    <option key={room.id} value={room.id}>{room.name}</option>
                  ))}
                </select>
              </label>
              <label className="ak-workspace-field">
                <span>{copy.owner}</span>
                <input
                  className="ak-workspace-input"
                  value={selectedRoomData?.ownerName || '-'}
                  readOnly
                />
              </label>
              <label className="ak-workspace-field">
                <span>{copy.roomType}</span>
                <input
                  className="ak-workspace-input"
                  value={selectedRoomData?.shared ? copy.sharedRoom : copy.ownedRoom}
                  readOnly
                />
              </label>
            </div>
            <div className="ak-workspace-inline-actions ak-workspace-inline-actions-top">
              {selectedRoom && (
                <a href={`/rooms/${selectedRoom}`} className="ak-workspace-link-btn">
                  <LinkIcon className="hi-s me-1" />
                  {copy.openRoom}
                </a>
              )}
            </div>
          </div>

          {!roomsLoading && !roomOptions.length && (
            <div className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top">
              <p className="ak-workspace-status mb-0">{copy.noRooms}</p>
            </div>
          )}

          {selectedRoom && (
            <div className="ak-workspace-tool-card ak-workspace-tool-grid-gap-top ak-workspace-files-library">
              <div className="ak-workspace-tool-head">
                <h3>
                  <FolderIcon className="hi-s me-1" />
                  {selectedRoomData?.name || selectedRoom}
                </h3>
              </div>
              <Presentation key={selectedRoom} friendlyId={selectedRoom} />
            </div>
          )}
        </section>
      </div>
    </div>
  );
}
