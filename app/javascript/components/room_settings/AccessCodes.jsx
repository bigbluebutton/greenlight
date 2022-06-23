import React from 'react';
import { Button, Row, Stack } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import { TrashIcon, DuplicateIcon } from '@heroicons/react/outline';
import useGenerateAccessCode from '../../hooks/mutations/rooms/useGenerateAccessCode';
import useDeleteAccessCode from '../../hooks/mutations/rooms/useDeleteAccessCode';
import useAccessCodes from '../../hooks/queries/rooms/useAccessCodes';

const copyAccessCode = (accessCode) => navigator.clipboard.writeText(accessCode);

export default function AccessCodes() {
  const { friendlyId } = useParams();
  const { handleGenerateAccessCode } = useGenerateAccessCode(friendlyId);
  const { handleDeleteAccessCode } = useDeleteAccessCode(friendlyId);
  const { data: accessCodes } = useAccessCodes(friendlyId);

  return (
    <>
      <Row className="my-3">
        <h6 className="text-primary">Generate access code for viewers</h6>
        {
          accessCodes?.viewer_access_code
            ? (
              <Stack direction="horizontal">
                <div className="access-code-input w-100">
                  <input type="text" className="form-control" value={accessCodes.viewer_access_code} />
                  <Button
                    variant="font-awesome"
                    onClick={() => copyAccessCode(accessCodes.viewer_access_code)}
                  >
                    <DuplicateIcon className="w-24 text-muted" />
                  </Button>
                </div>
                <Button
                  className="px-3"
                  variant="font-awesome"
                  onClick={() => handleDeleteAccessCode('Viewer')}
                >
                  <TrashIcon className="w-24 text-muted" />
                </Button>
              </Stack>
            )
            : (
              <div>
                <Button
                  variant="primary-light"
                  onClick={() => handleGenerateAccessCode('Viewer')}
                >
                  Generate
                </Button>
              </div>
            )
        }
      </Row>
      <Row>
        <h6 className="text-primary">Generate access code for moderators</h6>
        {
          accessCodes?.moderator_access_code
            ? (
              <Stack direction="horizontal">
                <div className="access-code-input w-100">
                  <input type="text" className="form-control" value={accessCodes.moderator_access_code} />
                  <Button
                    variant="font-awesome"
                    onClick={() => copyAccessCode(accessCodes.moderator_access_code)}
                  >
                    <DuplicateIcon className="w-24 text-muted" />
                  </Button>
                </div>
                <Button
                  className="px-3"
                  variant="font-awesome"
                  onClick={() => handleDeleteAccessCode('Moderator')}
                >
                  <TrashIcon className="w-24 text-muted" />
                </Button>
              </Stack>
            )
            : (
              <div>
                <Button
                  variant="primary-light"
                  onClick={() => handleGenerateAccessCode('Moderator')}
                >
                  Generate
                </Button>
              </div>
            )
        }
      </Row>
    </>
  );
}
