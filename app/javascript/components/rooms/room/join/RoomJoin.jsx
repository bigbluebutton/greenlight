/* eslint-disable consistent-return */
import React, { useState, useEffect } from 'react';
import Card from 'react-bootstrap/Card';
import {
  Navigate, Link, useLocation, useParams,
} from 'react-router-dom';
import {
  Button, Col, Row, Spinner, Stack, Form as RegularForm,
} from 'react-bootstrap';
import toast from 'react-hot-toast';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import usePublicRoom from '../../../../hooks/queries/rooms/usePublicRoom';
import { useAuth } from '../../../../contexts/auth/AuthProvider';
import useRoomStatus from '../../../../hooks/mutations/rooms/useRoomStatus';
import useEnv from '../../../../hooks/queries/env/useEnv';
import { joinFormConfig, joinFormFields as fields } from '../../../../helpers/forms/JoinFormHelpers';
import subscribeToRoom from '../../../../channels/rooms_channel';
import RequireAuthentication from './RequireAuthentication';
import GGSpinner from '../../../shared_components/utilities/GGSpinner';
import Logo from '../../../shared_components/Logo';
import Avatar from '../../../users/user/Avatar';
import Form from '../../../shared_components/forms/Form';
import FormControl from '../../../shared_components/forms/FormControl';

export default function RoomJoin() {
  const { t } = useTranslation();
  const currentUser = useAuth();
  const { friendlyId } = useParams();
  const [hasStarted, setHasStarted] = useState(false);

  const publicRoom = usePublicRoom(friendlyId);
  const roomStatusAPI = useRoomStatus(friendlyId);

  const { isLoading, data: env } = useEnv();

  const methods = useForm(joinFormConfig);

  const location = useLocation();
  const path = encodeURIComponent(location.pathname);

  useEffect(() => { // set cookie to return to if needed
    document.cookie = `location=${path};path=/;`;

    return () => { // delete redirect location when unmounting
      document.cookie = 'location=;path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT';
    };
  }, []);

  const handleJoin = (data) => {
    document.cookie = 'location=;path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT'; // delete redirect location

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
    return <RequireAuthentication path={path} />;
  }

  if (publicRoom.data.owner_id === currentUser?.id) {
    return <Navigate to={`/rooms/${publicRoom.data.friendly_id}`} />;
  }

  const hasAccessCode = publicRoom.data?.viewer_access_code || publicRoom.data?.moderator_access_code;

  if (!publicRoom.data?.viewer_access_code && publicRoom.data?.moderator_access_code) {
    fields.accessCode.label = t('room.settings.mod_access_code_optional');
  } else {
    fields.accessCode.label = t('room.settings.access_code');
  }

  const WaitingPage = (
    <Stack direction="horizontal" className="py-4">
      <div>
        <h5>{ t('room.meeting.meeting_not_started') }</h5>
        <span className="text-muted">{ t('room.meeting.join_meeting_automatically') }</span>
      </div>
      <div className="d-block ms-auto">
        <GGSpinner />
      </div>
    </Stack>
  );

  if (isLoading) return <Spinner />;

  return (
    <div className="vertical-buffer">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-6 mx-auto p-0 border-0 shadow-sm">
        <Card.Body className="pt-4 px-5">
          <Row>
            <Col className="col-xxl-8">
              <span className="text-muted">{ t('room.meeting.meeting_invitation') }</span>
              <h1 className="mt-2">
                {publicRoom.data.name}
                {publicRoom.isFetching && <Spinner />}
              </h1>
            </Col>
            <Col>
              <Stack direction="vertical" gap={3}>
                <Avatar className="d-block ms-auto me-auto" avatar={publicRoom?.data.owner_avatar} radius={100} />
                <h5 className="text-center">{publicRoom?.data.owner_name}</h5>
              </Stack>
            </Col>
          </Row>
        </Card.Body>
        <Card.Footer className="px-5 pb-3 bg-white border-2">
          {(roomStatusAPI.isSuccess && !roomStatusAPI.data.status) ? WaitingPage : (
            <Form methods={methods} onSubmit={handleJoin}>
              <FormControl field={fields.name} type="text" disabled={currentUser?.signed_in} autoFocus={!currentUser?.signed_in} />
              {hasAccessCode && <FormControl field={fields.accessCode} type="text" autoFocus={currentUser?.signed_in} />}

              {publicRoom?.data?.recording_consent === 'true' && (
                <div className="mb-1">
                  <input
                    id="consentCheck"
                    className="form-check-input fs-5 me-2"
                    type="checkbox"
                  />
                  <label className="d-inline text-danger align-middle" htmlFor="consentCheck">
                    {t('room.meeting.recording_consent')}
                  </label>
                </div>
              )}

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
      { !currentUser?.signed_in && (
        env.OPENID_CONNECT ? (
          <Stack direction="horizontal" className="d-flex justify-content-center text-muted mt-3"> { t('authentication.already_have_account') }
            <RegularForm action="/auth/openid_connect" method="POST" data-turbo="false">
              <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]').content} />
              <Button variant="link" className="cursor-pointer ms-2 ps-0" type="submit">{t('authentication.sign_in')}</Button>
            </RegularForm>
          </Stack>
        ) : (
          <div className="text-center text-muted mt-3"> { t('authentication.already_have_account') }
            <Link to={`/signin?location=${path}`} className="text-link ms-1"> { t('authentication.sign_in') } </Link>
          </div>
        )
      )}
    </div>
  );
}
