import React from 'react';
import { Card, Form, Stack } from 'react-bootstrap';
import Button from 'react-bootstrap/Button';
import ButtonLink from '../shared_components/utilities/ButtonLink';
import Spinner from '../shared_components/utilities/Spinner';
import useEnv from '../../hooks/queries/env/useEnv';
import Logo from '../shared_components/Logo';
import { useAuth } from '../../contexts/auth/AuthProvider';

export default function HomePage() {
  const { isLoading, data: env } = useEnv();
  const currentUser = useAuth();

  if (isLoading) return <Spinner />;

  return (
    <div className="vertical-center">
      <div className="text-center mb-4">
        <Logo size="large" />
      </div>
      <Card className="col-md-8 mx-auto p-5 border-0 shadow-sm text-center">
        <h1 className="mt-4"> Welcome to BigBlueButton. </h1>
        <div className="mt-4 px-xxl-5">
          {
            (() => {
              if (currentUser?.signed_in) {
                return (
                  <div className="text-start">
                    <h6> Please enter the URL of your meeting. </h6>
                    <Stack direction="horizontal">
                      <input className="form-control" id="joinUrl" />
                      <Button variant="brand" className="ms-2">Join</Button>
                    </Stack>
                  </div>
                );
              }
              return (
                <>
                  <span className="text-muted">
                    Greenlight is a simple front-end for your BigBlueButton open-source web
                    conferencing server.
                    You can create your own rooms to host sessions, or
                    join others using a short and convenient link.
                  </span>
                  <Stack direction="horizontal" className="d-block mx-auto mt-5 mb-2">
                    {env.OPENID_CONNECT ? (
                      <Form action="/auth/openid_connect" method="POST" data-turbo="false">
                        <input
                          type="hidden"
                          name="authenticity_token"
                          value={document.querySelector('meta[name="csrf-token"]').content}
                        />
                        <input
                          variant="brand-backward"
                          className="btn btn-xlg"
                          type="submit"
                          value="Sign Up"
                        />
                        <input
                          variant="brand"
                          className="btn btn-xlg mx-4"
                          type="submit"
                          value="Sign In"
                        />
                      </Form>
                    ) : (
                      <>
                        <ButtonLink to="/signup" variant="brand-backward" className="btn btn-xlg">Sign
                          Up
                        </ButtonLink>
                        <ButtonLink to="/signin" variant="brand" className="btn btn-xlg mx-4">Sign
                          In
                        </ButtonLink>
                      </>
                    )}
                  </Stack>
                </>
              );
            }
            )()
          }
        </div>
      </Card>
    </div>
  );
}
