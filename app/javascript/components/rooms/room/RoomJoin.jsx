import React, { useState, useEffect } from 'react';
import Card from 'react-bootstrap/Card';
import { useParams } from 'react-router-dom';
import {
  Button, Col, Row, Stack,
} from 'react-bootstrap';
import toast from 'react-hot-toast';
import usePublicRoom from '../../../hooks/queries/rooms/usePublicRoom';
import Spinner from '../../shared_components/utilities/Spinner';
import useRoomStatus from '../../../hooks/mutations/rooms/useRoomStatus';
import subscribeToRoom from '../../../channels/rooms_channel';
import Logo from '../../shared_components/Logo';

export default function RoomJoin() {
  const { friendlyId } = useParams();

  const [name, setName] = useState('');
  const [accessCode, setAccessCode] = useState('');
  const [hasStarted, setHasStarted] = useState(false);

  const publicRoom = usePublicRoom(friendlyId);
  const roomStatusAPI = useRoomStatus(friendlyId);

  const handleJoin = () => roomStatusAPI.mutate({ name, access_code: accessCode });

  // eslint-disable-next-line consistent-return
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
      toast.success('Meeting started.');
      console.info(`Attempting to join the room(friendly_id): ${friendlyId} meeting in 7s.`);
      setTimeout(handleJoin, 7000); // TODO: Improve this race condition handling by the backend.
    }
  }, [hasStarted]);

  useEffect(() => {
    // UI synchronization on failing join attempt:
    //  When the room status API returns an error indicating a failed join attempt it's highly due to stale credentials.
    //  In such case, users from a UX perspective will appreciate having the UI updated informing them about the case.
    //  i.e: Indicating the lack of providing access code value for cases where access code was generated while the user was waiting.
    if (roomStatusAPI.isError) {
      publicRoom.refetch();
    }
  }, [roomStatusAPI.isError]);

  if (publicRoom.isLoading) return <Spinner />;

  return (
    <div className="vertical-center">
      <div className="text-center pb-4">
        <Logo size="medium" />
      </div>
      <Card className="col-md-6 mx-auto p-0 border-0 shadow-sm">
        <Card.Body className="p-4">
          <Row>
            <Stack>
              <p className="text-muted mb-0">You have been invited to join</p>
              <h1>
                {publicRoom.data.name}
                {publicRoom.isFetching && <Spinner />}
              </h1>
            </Stack>
          </Row>
        </Card.Body>
        <Card.Footer className="p-4 bg-white">
          {(roomStatusAPI.isSuccess && !roomStatusAPI.data.status) ? (
            <div className="mt-3">
              <Row>
                <Col className="col-10">
                  <p className="mb-1">The meeting hasn&apos;t started yet</p>
                  <p className="mb-0 text-muted">You will automatically join when the meeting starts</p>
                </Col>
                <Col className="col-2">
                  <Spinner className="float-end" />
                </Col>
              </Row>
            </div>
          ) : (
            <>
              <label htmlFor="join-name" className="small text-muted d-block"> Name
                <input
                  type="text"
                  id="join-name"
                  placeholder="Enter your name"
                  className="form-control"
                  value={name}
                  onChange={(event) => setName(event.target.value)}
                />
              </label>
              {publicRoom.data?.viewer_access_code
                && (
                  <div className="mt-2">
                    <label htmlFor="access-code" className="small text-muted d-block"> Access Code
                      <input
                        type="text"
                        id="access-code"
                        placeholder="Enter the access code"
                        className="form-control"
                        value={accessCode}
                        onChange={(event) => setAccessCode(event.target.value)}
                      />
                    </label>
                    {
                      (roomStatusAPI.isError)
                      && (
                        <p className="text-danger"> Wrong access code. </p>
                      )
                    }
                  </div>
                )}
              {(!(publicRoom.data?.viewer_access_code) && publicRoom.data?.moderator_access_code)
                && (
                  <div className="mt-2">
                    <label htmlFor="access-code" className="small text-muted d-block"> Moderator Access Code (optional)
                      <input
                        type="text"
                        id="access-code"
                        placeholder="Enter the access code"
                        className="form-control"
                        value={accessCode}
                        onChange={(event) => setAccessCode(event.target.value)}
                      />
                    </label>
                    {
                      (roomStatusAPI.isError)
                      && (
                        <p className="text-danger"> Wrong access code. </p>
                      )
                    }
                  </div>
                )}
              <Button
                variant="brand"
                className="mt-3 d-block float-end"
                onClick={handleJoin}
                disabled={publicRoom.isFetching || roomStatusAPI.isLoading}
              >
                Join Session
                {roomStatusAPI.isLoading && <Spinner />}
              </Button>
            </>
          )}
        </Card.Footer>
      </Card>
    </div>
  );
}
