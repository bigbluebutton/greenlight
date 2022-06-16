import React, { useEffect, useState } from 'react';
import Card from 'react-bootstrap/Card';
import useVerifyReset from '../../hooks/mutations/users/useVerifyReset';
import FormLogo from '../forms/FormLogo';
import ResetPwdForm from '../forms/ResetPwdForm';
import Spinner from '../shared/stylings/Spinner';

export default function ResetPassword() {
  const [refreshToken, setRefreshToken] = useState(null);
  const { verify, isLoading } = useVerifyReset(setRefreshToken);

  useEffect(() => {
    verify();
  }, []);

  if (isLoading) return <Spinner />;

  return (
    <div className="wide-background">
      <div className="vertical-center">
        <FormLogo />
        <Card className="col-md-4 mx-auto p-4 border-0 shadow-sm">
          <ResetPwdForm token={refreshToken} />
        </Card>
      </div>
    </div>
  );
}
