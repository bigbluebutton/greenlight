import React from 'react';
import { Button, Row, Stack } from 'react-bootstrap';
import { useParams } from 'react-router-dom';
import { TrashIcon, DuplicateIcon } from '@heroicons/react/outline';
import { toast } from 'react-hot-toast';
import useGenerateAccessCode from '../../hooks/mutations/rooms/useGenerateAccessCode';
import useDeleteAccessCode from '../../hooks/mutations/rooms/useDeleteAccessCode';
import useAccessCodes from '../../hooks/queries/rooms/useAccessCodes';

const copyAccessCode = (accessCode) => {
  navigator.clipboard.writeText(accessCode);
  toast.success('Copied');
};

export default function AccessCodes() {
  const { friendlyId } = useParams();
  const generateAccessCode = useGenerateAccessCode(friendlyId);
  const deleteAccessCode = useDeleteAccessCode(friendlyId);
  const { data: accessCodes } = useAccessCodes(friendlyId);

  return (
    <>
      <Row className="my-3">
        <h6 className="text-brand">Generate access code for viewers</h6>
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
                    <DuplicateIcon className="hi-s text-muted" />
                  </Button>
                </div>
                <Button
                  className="px-3"
                  variant="font-awesome"
                  onClick={() => deleteAccessCode.mutate('Viewer')}
                >
                  <TrashIcon className="hi-s text-muted" />
                </Button>
              </Stack>
            )
            : (
              <div>
                <Button
                  variant="brand-backward"
                  onClick={() => generateAccessCode.mutate('Viewer')}
                >
                  Generate
                </Button>
              </div>
            )
        }
      </Row>
      <Row>
        <h6 className="text-brand">Generate access code for moderators</h6>
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
                    <DuplicateIcon className="hi-s text-muted" />
                  </Button>
                </div>
                <Button
                  className="px-3"
                  variant="font-awesome"
                  onClick={() => deleteAccessCode.mutate('Moderator')}
                >
                  <TrashIcon className="hi-s text-muted" />
                </Button>
              </Stack>
            )
            : (
              <div>
                <Button
                  variant="brand-backward"
                  onClick={() => generateAccessCode.mutate('Moderator')}
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
