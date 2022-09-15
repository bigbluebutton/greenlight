/* eslint-disable consistent-return */
import React, { useState, useEffect } from 'react';
import Card from 'react-bootstrap/Card';
import { Navigate, useParams } from 'react-router-dom';
import {
  Button, Col, Row, Stack,
} from 'react-bootstrap';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import usePublicRoom from '../../../hooks/queries/rooms/usePublicRoom';
import Spinner from '../../shared_components/utilities/Spinner';
import useRoomStatus from '../../../hooks/mutations/rooms/useRoomStatus';
import subscribeToRoom from '../../../channels/rooms_channel';
import Logo from '../../shared_components/Logo';
import { useAuth } from '../../../contexts/auth/AuthProvider';
import { joinFormConfig, joinFormFields as fields } from '../../../helpers/forms/JoinFormHelpers';
import Form from '../../shared_components/forms/Form';
import FormControl from '../../shared_components/forms/FormControl';

export default function RoomJoin() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const { friendlyId } = useParams();
  const [hasStarted, setHasStarted] = useState(false);

  const publicRoom = usePublicRoom(friendlyId);
  const roomStatusAPI = useRoomStatus(friendlyId);

  const methods = useForm(joinFormConfig);

  const handleJoin = (data) => {
    if (publicRoom?.data.viewer_access_code && !methods.getValues('access_code')) {
      return methods.setError('access_code', { type: 'required', message: t('room.settings.access_code_required') }, { shouldFocus: true });
    }

    roomStatusAPI.mutate(data);
  };
  const reset = () => { setHasStarted(false); };// Reset pipeline;

  useEffect(() => {
    // Default Join name to authenticated user full name.
    if (currentUser?.name) {
      methods.setValue('name', currentUser.name);
    }
  }, [currentUser?.name]);

  useEffect(() => {
    // Room channel subscription:
    if (roomStatusAPI.isSuccess) {
      //  When the user provides valid input (name, codes) the UI will subscribe to the room channel.
      const channel = subscribeToRoom(friendlyId, { onReceived: () => { setHasStarted(true); } });

      //  Cleanup: On component unmouting any opened channel subscriptions will be closed.
      return () => {
        channel.unsubscribe();
        console.info(`WS: unsubscribed from room(friendly_id): ${friendlyId} channel.`);
      };
    }
  }, [roomStatusAPI.isSuccess]);

  useEffect(() => {
    // Meeting started:
    //  When meeting starts thig logic will be fired, indicating the event to waiting users (thorugh a toast) for UX matter.
    //  Logging the event for debugging purposes and refetching the join logic with the user's given input (name & codes).
    //  With a delay of 7s to give reasonable time for the meeting to fully start on the BBB server.
    if (hasStarted) {
      toast.success(t('toast.success.room.meeting_started'));
      console.info(`Attempting to join the room(friendly_id): ${friendlyId} meeting in 7s.`);
      setTimeout(methods.handleSubmit(handleJoin), 7000); // TODO: Improve this race condition handling by the backend.
      reset();// Resetting the Join component.
    }
  }, [hasStarted]);

  useEffect(() => {
    // UI synchronization on failing join attempt:
    //  When the room status API returns an error indicating a failed join attempt it's highly due to stale credentials.
    //  In such case, users from a UX perspective will appreciate having the UI updated informing them about the case.
    //  i.e: Indicating the lack of providing access code value for cases where access code was generated while the user was waiting.
    if (roomStatusAPI.isError) {
      // Invalid Access Code SSE (Server Side Error):
      if (roomStatusAPI.error.response.status === 403) {
        methods.setError('access_code', { type: 'SSE', message: t('room.settings.wrong_access_code') }, { shouldFocus: true });
      }

      publicRoom.refetch();// Refetching room public information.
      reset();// Resetting the Join component.
    }
  }, [roomStatusAPI.isError]);

  if (publicRoom.isLoading) return <Spinner />;

  if (!currentUser.signed_in && publicRoom.data.require_authentication === 'true') {
    toast.error(t('toast.error.must_be_signed_in_to_join_room'));
    return <Navigate replace to="/" />;
  }

  const hasAccessCode = publicRoom.data?.viewer_access_code || publicRoom.data?.moderator_access_code;

  if (!publicRoom.data?.viewer_access_code && publicRoom.data?.moderator_access_code) {
    fields.accessCode.label = t('room.settings.mod_access_code_optional');
  } else {
    fields.accessCode.label = t('room.settings.access_code');
  }

  const WaitingPage = (
    <div className="mt-3">
      <Row>
        <Col className="col-10">
          <p className="mb-1">{ t('room.meeting.meeting_not_started') }</p>
          <p className="mb-0 text-muted">{ t('room.meeting.join_meeting_automatically') }</p>
        </Col>
        <Col className="col-2">
          <Spinner className="float-end" />
        </Col>
      </Row>
    </div>
  );

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-6 mx-auto p-0 border-0 shadow-sm">
        <Card.Body className="p-4">
          <Row>
            <Stack>
              <p className="text-muted mb-0">{ t('room.meeting.meeting_invitation') }</p>
              <h1>
                {publicRoom.data.name}
                {publicRoom.isFetching && <Spinner />}
              </h1>
            </Stack>
          </Row>
        </Card.Body>
        <Card.Footer className="p-4 bg-white">
          {(roomStatusAPI.isSuccess && !roomStatusAPI.data.status) ? WaitingPage : (
            <Form methods={methods} onSubmit={handleJoin}>
              <FormControl field={fields.name} type="text" disabled={currentUser?.signed_in} autoFocus={!currentUser?.signed_in} />
              {hasAccessCode && <FormControl field={fields.accessCode} type="text" autoFocus={currentUser?.signed_in} />}
              <Button
                variant="brand"
                className="mt-3 d-block float-end"
                type="submit"
                disabled={publicRoom.isFetching || roomStatusAPI.isLoading}
              >
                { t('room.meeting.join_meeting') }
                {roomStatusAPI.isLoading && <Spinner />}
              </Button>
            </Form>
          )}
        </Card.Footer>
      </Card>
    </div>
  );
}
