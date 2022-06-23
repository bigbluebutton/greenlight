import React from 'react';
import { Button, Card } from 'react-bootstrap';
import { useAuth } from '../../contexts/auth/AuthProvider';
import useCreateActivation from '../../hooks/mutations/account_activation/useCreateActivation';
import FormLogo from '../forms/FormLogo';
import Spinner from '../shared/stylings/Spinner';

export default function ResendVerification() {
  const currentUser = useAuth();
  const { onClick: createActivation, isLoading } = useCreateActivation(currentUser.email);

  return (
    <div className="wide-background">
      <div className="vertical-center">
        <FormLogo />
        <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
          <Card.Title className="text-center pb-2"> Account Verification </Card.Title>
          <Card.Text>
            Your account has not been verified yet.

            In order to use Greenlight full features you are kindly invited to verify your email.

            If you haven&apos;t received an activation link or if you are having a problem using it,
            please click the resend button below to get a new link.

            You can still update your profile information in case you used the wrong email address.
          </Card.Text>
          <Button onClick={createActivation} disabled={isLoading}>
            Resend Verification {isLoading && <Spinner />}
          </Button>
        </Card>
      </div>
    </div>
  );
}
