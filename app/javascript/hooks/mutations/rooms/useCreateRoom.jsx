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

import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import axios from '../../../helpers/Axios';
import { fileValidation, handleError } from '../../../helpers/FileValidationHelper';

export function buildCreatePayload(room, fallbackUserId = '') {
  const roomPayload = {
    name: room.name,
    user_id: room.user_id || fallbackUserId,
    icon_key: room.icon_key || 'general',
  };

  if (room?.presentation_source_friendly_id) {
    roomPayload.source_friendly_id = room.presentation_source_friendly_id;
  }

  if (room?.presentation_global_source_key) {
    roomPayload.global_source_key = room.presentation_global_source_key;
  }

  const hasFileUpload = room?.presentation || room?.thumbnail_image;

  if (room?.presentation) {
    fileValidation(room.presentation, 'presentation');
  }

  if (room?.thumbnail_image) {
    fileValidation(room.thumbnail_image, 'image');
  }

  if (hasFileUpload) {
    const formData = new FormData();
    formData.append('room[name]', roomPayload.name);
    formData.append('room[user_id]', roomPayload.user_id);
    formData.append('room[icon_key]', roomPayload.icon_key);
    if (roomPayload.source_friendly_id) formData.append('room[source_friendly_id]', roomPayload.source_friendly_id);
    if (roomPayload.global_source_key) formData.append('room[global_source_key]', roomPayload.global_source_key);
    if (room.thumbnail_image) formData.append('room[thumbnail_image]', room.thumbnail_image);
    if (room.presentation) formData.append('room[presentation]', room.presentation);
    return {
      data: formData,
      config: {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      },
    };
  }

  return { data: { room: roomPayload }, config: {} };
}

export async function applyRoomDefaults(friendlyId, room) {
  const settingEntries = [
    ['record', room.record],
    ['glRequireAuthentication', room.glRequireAuthentication],
    ['guestPolicy', room.guestPolicy],
    ['glAnyoneCanStart', room.glAnyoneCanStart],
    ['glAnyoneJoinAsModerator', room.glAnyoneJoinAsModerator],
    ['muteOnStart', room.muteOnStart],
  ];

  await Promise.allSettled(
    settingEntries.map(([settingName, settingValue]) => axios.patch(
      `/room_settings/${friendlyId}.json`,
      {
        room_setting: {
          settingName,
          settingValue: settingName === 'guestPolicy'
            ? (settingValue ? 'ASK_MODERATOR' : 'ALWAYS_ACCEPT')
            : settingValue,
        },
      },
    )),
  );
}

export default function useCreateRoom({ userId, onSettled }) {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const ROOMSLISTQUERYKEY = ['getRooms', { search: '' }]; // TODO: amir - create a central store for query keys.
  const queryClient = useQueryClient();

  // Optimistically adds the room to the rooms querries cache.
  const optimisticCreateRoom = async (data) => {
    const newRoom = { ...data };
    // Prepare the new room to be cached.
    newRoom.friendly_id = `${Date.now()}`; // TODO: amir - Revisit this.
    newRoom.optimistic = true; // Mark the room object as optimistic.

    // Cancel any outgoing refetches (so they don't overwrite our optimistic update)
    await queryClient.cancelQueries(ROOMSLISTQUERYKEY);

    // Snapshot the previous value
    const oldRooms = queryClient.getQueryData(ROOMSLISTQUERYKEY);
    // Optimistically update to the new value
    queryClient.setQueryData(ROOMSLISTQUERYKEY, (old) => old?.concat([newRoom]));

    // Return a context object with the snapshotted value
    return { oldRooms };
  };

  return useMutation(
    (room) => {
      const { data, config } = buildCreatePayload(room, userId);
      return axios.post('/rooms.json', data, config);
    },
    { // Mutation config.
      onMutate: optimisticCreateRoom,
      onSuccess: async (response, room) => {
        const createdPath = response?.data?.data;

        if (createdPath) {
          const segments = createdPath.split('/').filter(Boolean);
          const friendlyId = segments[segments.length - 1];

          if (friendlyId) {
            await applyRoomDefaults(friendlyId, room);
          }

          if (room?.post_create_tab === 'list') {
            navigate('/rooms');
          } else if (room?.post_create_tab === 'settings' || room?.post_create_tab === 'files') {
            navigate(`${createdPath}?tab=${room.post_create_tab}`);
          } else {
            navigate(createdPath);
          }
        }

        toast.success(t('toast.success.room.room_created'));
      },
      // If the mutation fails, use the context returned from onMutate to roll back
      onError: (err, newRoom, context) => {
        if (context?.oldRooms) {
          queryClient.setQueryData(ROOMSLISTQUERYKEY, context.oldRooms);
        }
        // specifc toast for room limit being met
        if (err?.response?.data?.errors === 'RoomLimitError') {
          toast.error(t('toast.error.rooms.room_limit'));
        } else {
          handleError(err, t, toast);
        }
      },
      // Always refetch after error or success:
      onSettled: () => {
        queryClient.invalidateQueries(['getRooms']);
        queryClient.invalidateQueries(['getUserPresentationLibrary']);
        queryClient.invalidateQueries(['getRoomPresentationLibrary']);
        queryClient.invalidateQueries(['getGlobalPresentationTemplates']);
        if (onSettled) onSettled();
      },
    },
  );
}
