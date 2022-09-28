import React from 'react';
import { Card } from 'react-bootstrap';
import { CloudArrowUpIcon } from '@heroicons/react/24/outline';
import { useTranslation } from 'react-i18next';
import useUpdateSiteSetting from '../../../../hooks/mutations/admin/site_settings/useUpdateSiteSetting';
import FilesDragAndDrop from '../../../shared_components/utilities/FilesDragAndDrop';

export default function BrandingImage() {
  const { t } = useTranslation();
  const updateSiteSetting = useUpdateSiteSetting('BrandingImage');

  return (
    <div className="mb-3">
      <h5> { t('admin.site_settings.appearance.brand_image') } </h5>
      <FilesDragAndDrop
        numOfFiles={1}
        onDrop={(files) => updateSiteSetting.mutate(files[0])}
        formats={['.jpg', '.png', '.svg']}
      >
        <Card className="border border-2 border-whitesmoke mt-3 text-center">
          <label htmlFor="file" className="presentation-upload">
            <Card.Body className="text-secondary cursor-pointer">
              <div className="icon-circle rounded-circle d-block mx-auto mb-3">
                <CloudArrowUpIcon className="hi-l text-brand d-block mx-auto pt-4" />
              </div>
              <input
                id="file"
                className="d-none"
                type="file"
                onChange={(e) => updateSiteSetting.mutate(e.target.files[0])}
                accept=".jpg,.png,.svg"
              />
              <Card.Title className="text-brand">
                { t('admin.site_settings.appearance.click_to_upload') }
                <span className="fs-5 fw-normal text-muted">
                  { t('admin.site_settings.appearance.drag_and_drop') }
                </span>
              </Card.Title>
              <span className="text-muted">
                { t('admin.site_settings.appearance.upload_brand_image_description') }
              </span>
            </Card.Body>
          </label>
        </Card>
      </FilesDragAndDrop>
    </div>
  );
}
