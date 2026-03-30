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

import React, { useMemo, useState } from 'react';
import {
  Button, Card, Modal as BootstrapModal, Stack, Table,
} from 'react-bootstrap';
import { EyeIcon, TrashIcon } from '@heroicons/react/24/outline';
import { useParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import Modal from '../../../shared_components/modals/Modal';
import SharedAccessForm from './forms/SharedAccessForm';
import Avatar from '../../../users/user/Avatar';
import SearchBar from '../../../shared_components/search/SearchBar';
import useDeleteSharedAccess from '../../../../hooks/mutations/shared_accesses/useDeleteSharedAccess';
import useSharedUsers from '../../../../hooks/queries/shared_accesses/useSharedUsers';
import useRoom from '../../../../hooks/queries/rooms/useRoom';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import { getCurrentLanguage } from '../../../../helpers/LanguageHelper';

const PARTICIPANT_COPY = {
  en: {
    participant: 'Participant',
    email: 'Email',
    role: 'Role',
    access: 'Access',
    actions: 'Actions',
    roomOwner: 'Room Owner',
    sharedUser: 'Shared Participant',
    noUserFound: 'No participants found.',
    viewDetails: 'View details',
    detailTitle: 'Participant details',
    detailSubtitle: 'Profile and access details for this room participant.',
    close: 'Close',
  },
  tr: {
    participant: 'Katılımcı',
    email: 'E-posta',
    role: 'Rol',
    access: 'Erişim',
    actions: 'İşlemler',
    roomOwner: 'Oda Sahibi',
    sharedUser: 'Paylaşılan Katılımcı',
    noUserFound: 'Katılımcı bulunamadı.',
    viewDetails: 'Detayları gör',
    detailTitle: 'Katılımcı detayları',
    detailSubtitle: 'Bu oda katılımcısı için profil ve erişim detayları.',
    close: 'Kapat',
  },
};

export default function SharedAccess() {
  const { t, i18n } = useTranslation();
  const { friendlyId } = useParams();
  const [searchInput, setSearchInput] = useState('');
  const [selectedParticipant, setSelectedParticipant] = useState(null);
  const { data: sharedUsers } = useSharedUsers(friendlyId, searchInput);
  const deleteSharedAccess = useDeleteSharedAccess(friendlyId);
  const { data: room } = useRoom(friendlyId);
  const currentUser = useAuth();
  const isAdmin = currentUser?.role?.name === 'Administrator';
  const language = getCurrentLanguage(i18n, currentUser?.language || 'en');
  const copy = PARTICIPANT_COPY[language];

  const filteredParticipants = useMemo(() => {
    const normalizedSearch = searchInput.trim().toLowerCase();
    const participants = [];

    if (room?.owner_name) {
      const ownerParticipant = {
        id: `owner-${room.id}`,
        name: room.owner_name,
        email: room.owner_email,
        role_name: room.owner_role_name,
        avatar: null,
        accessLabel: copy.roomOwner,
        canRemove: false,
      };
      const matchesOwner = !normalizedSearch || [
        ownerParticipant.name,
        ownerParticipant.email,
        ownerParticipant.role_name,
      ].some((value) => value && value.toLowerCase().includes(normalizedSearch));

      if (matchesOwner) participants.push(ownerParticipant);
    }

    (Array.isArray(sharedUsers) ? sharedUsers : []).forEach((user) => {
      participants.push({
        ...user,
        accessLabel: copy.sharedUser,
        canRemove: !room?.shared || isAdmin,
      });
    });

    return participants;
  }, [
    copy.roomOwner,
    copy.sharedUser,
    isAdmin,
    room?.id,
    room?.owner_email,
    room?.owner_name,
    room?.owner_role_name,
    room?.shared,
    searchInput,
    sharedUsers,
  ]);

  return (
    <>
      <div id="shared-access-list" className="pt-3">
        <Stack direction="horizontal" className="w-100 flex-wrap gap-2">
          <div>
            <SearchBar searchInput={searchInput} setSearchInput={setSearchInput} />
          </div>
          { (!room?.shared || isAdmin) && (
            <Modal
              modalButton={(
                <Button
                  variant="brand-outline"
                  className="ms-auto"
                >{t('room.shared_access.add_share_access')}
                </Button>
)}
              title={t('room.shared_access.share_room_access')}
              body={<SharedAccessForm />}
              size="lg"
              id="shared-access-modal"
            />
          )}
        </Stack>
        <Card className="border-0 card-shadow mt-3">
          <Card.Body className="p-0">
            <Table hover responsive className="text-secondary mb-0">
              <thead>
                <tr className="text-muted small">
                  <th className="fw-normal">{copy.participant}</th>
                  <th className="fw-normal">{copy.email}</th>
                  <th className="fw-normal">{copy.role}</th>
                  <th className="fw-normal">{copy.access}</th>
                  <th className="fw-normal text-end">{copy.actions}</th>
                </tr>
              </thead>
              <tbody className="border-top-0">
                {!filteredParticipants.length && (
                  <tr>
                    <td colSpan="5" className="fw-semibold py-4 text-center">{copy.noUserFound}</td>
                  </tr>
                )}
                {filteredParticipants.map((user) => (
                  <tr key={user.id} className="align-middle">
                    <td>
                      <button
                        type="button"
                        className="btn btn-link p-0 text-decoration-none text-start"
                        onClick={() => setSelectedParticipant(user)}
                      >
                        <Stack direction="horizontal" className="py-2">
                          <Avatar avatar={user.avatar || ''} size="small" />
                          <span className="text-brand fw-semibold ps-3">{user.name}</span>
                        </Stack>
                      </button>
                    </td>
                    <td>{user.email || '-'}</td>
                    <td>{user.role_name || '-'}</td>
                    <td>{user.accessLabel}</td>
                    <td>
                      <Stack direction="horizontal" gap={1} className="justify-content-end py-2">
                        <Button
                          variant="icon"
                          className="pe-2"
                          onClick={() => setSelectedParticipant(user)}
                          title={copy.viewDetails}
                        >
                          <EyeIcon className="hi-s" />
                        </Button>
                        {user.canRemove && (
                          <Button
                            variant="icon"
                            className="pe-2"
                            onClick={() => deleteSharedAccess.mutate({ user_id: user.id })}
                          >
                            <TrashIcon className="hi-s" />
                          </Button>
                        )}
                      </Stack>
                    </td>
                  </tr>
                ))}
              </tbody>
            </Table>
          </Card.Body>
        </Card>
      </div>

      <BootstrapModal
        show={!!selectedParticipant}
        onHide={() => setSelectedParticipant(null)}
        centered
      >
        <BootstrapModal.Header closeButton>
          <BootstrapModal.Title>{copy.detailTitle}</BootstrapModal.Title>
        </BootstrapModal.Header>
        <BootstrapModal.Body>
          {selectedParticipant && (
            <div>
              <Stack direction="horizontal" gap={3} className="align-items-center">
                <Avatar avatar={selectedParticipant.avatar || ''} size="medium" />
                <div>
                  <h5 className="mb-1 text-brand">{selectedParticipant.name}</h5>
                  <p className="mb-0 text-muted">{copy.detailSubtitle}</p>
                </div>
              </Stack>
              <div className="mt-4">
                <div className="mb-3">
                  <div className="small text-uppercase text-muted fw-semibold">{copy.email}</div>
                  <div>{selectedParticipant.email || '-'}</div>
                </div>
                <div className="mb-3">
                  <div className="small text-uppercase text-muted fw-semibold">{copy.role}</div>
                  <div>{selectedParticipant.role_name || '-'}</div>
                </div>
                <div>
                  <div className="small text-uppercase text-muted fw-semibold">{copy.access}</div>
                  <div>{selectedParticipant.accessLabel}</div>
                </div>
              </div>
            </div>
          )}
        </BootstrapModal.Body>
        <BootstrapModal.Footer>
          <Button variant="brand-outline" onClick={() => setSelectedParticipant(null)}>
            {copy.close}
          </Button>
        </BootstrapModal.Footer>
      </BootstrapModal>
    </>
  );
}
