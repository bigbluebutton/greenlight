import { useEffect } from 'react';
import { toast } from 'react-toastify';
import subscribeToRoom from '../../../../channels/rooms_channel';

export const useLocationCookie = (path) => {
  useEffect(() => {
    const date = new Date();
    date.setTime(date.getTime() + (60 * 1000));
    document.cookie = `location=${path};path=/;expires=${date.toGMTString()}`;

    return () => {
      document.cookie = `location=${path};path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT`;
    };
  }, []);
};

export const useHandleJoin = ({
  publicRoom, methods, t, roomStatusAPI,
}) => (data) => {
  document.cookie = 'location=;path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT';

  if (publicRoom?.data.viewer_access_code && !methods.getValues('access_code')) {
    return methods.setError('access_code', { type: 'required', message: t('room.settings.access_code_required') }, { shouldFocus: true });
  }

  roomStatusAPI.mutate(data);
};

export const useDefaultJoinName = ({ currentUser, methods }) => {
  useEffect(() => {
    if (currentUser?.name) {
      methods.setValue('name', currentUser.name);
    }
  }, [currentUser?.name]);
};

export const useRoomChannelSubscription = ({ roomStatusAPI, friendlyId, setHasStarted }) => {
  useEffect(() => {
    if (roomStatusAPI.isSuccess) {
      const channel = subscribeToRoom(friendlyId, { onReceived: () => { setHasStarted(true); } });

      return () => {
        channel.unsubscribe();
        console.info(`WS: unsubscribed from room(friendly_id): ${friendlyId} channel.`);
      };
    }
  }, [roomStatusAPI.isSuccess]);
};

export const useMeetingStarted = ({ hasStarted, friendlyId, t, methods, handleJoin, reset }) => {
  useEffect(() => {
    if (hasStarted) {
      toast.success(t('toast.success.room.meeting_started'));
      toast.success('IM HERE')
      console.info(`Attempting to join the room(friendly_id): ${friendlyId} meeting in 7s.`);
      setTimeout(methods.handleSubmit(handleJoin), 7000);
      reset();
    }
  }, [hasStarted]);
};


export const useFailedJoinAttempt = ({
  roomStatusAPI, methods, t, publicRoom, reset,
}) => {
  useEffect(() => {
    if (roomStatusAPI.isError) {
      if (roomStatusAPI.error.response.status === 403) {
        methods.setError('access_code', { type: 'SSE', message: t('room.settings.wrong_access_code') }, { shouldFocus: true });
      }

      publicRoom.refetch();
      reset();
    }
  }, [roomStatusAPI.isError]);
};
