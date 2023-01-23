// import React from 'react';
// import PropTypes from 'prop-types';
// import { Table } from 'react-bootstrap';
// import { useTranslation } from 'react-i18next';
// import SortBy from '../shared_components/search/SortBy';
// import RecordingsListRowPlaceHolder from './RecordingsListRowPlaceHolder';
// import EmptyRecordingsList from './EmptyRecordingsList';
// import NoRecordingsFound from './NoRecordingsFound';
//
// export default function RecordingsList({
//   recordings, RecordingRow, recordingsProcessing, isLoading, searchInput,
// }) {
//   const { t } = useTranslation();
//
//   if ((recordings?.length || recordingsProcessing) || searchInput) {
//     return (
//       <Table id="recordings-table" className="table-bordered border border-2 mb-0 recordings-list" hover responsive>
//         <thead>
//           <tr className="text-muted small">
//             <th className="fw-normal border-end-0">{t('recording.name')}<SortBy fieldName="name" /></th>
//             <th className="fw-normal border-0">{t('recording.length')}<SortBy fieldName="length" /></th>
//             <th className="fw-normal border-0">{t('recording.users')}</th>
//             <th className="fw-normal border-0">{t('recording.visibility')}<SortBy fieldName="visibility" /></th>
//             <th className="fw-normal border-0">{t('recording.formats')}</th>
//             <th className="border-start-0" aria-label="options" />
//           </tr>
//         </thead>
//         <tbody className="border-top-0">
//           {
//             // eslint-disable-next-line react/no-array-index-key
//             (isLoading && [...Array(7)].map((val, idx) => (
//               <RecordingsListRowPlaceHolder key={idx} />
//             )))
//             || (recordings?.length && recordings?.map((recording) => (
//               <RecordingRow key={recording.id} recording={recording} />
//             )))
//             || <NoRecordingsFound searchInput={searchInput} />
//        }
//         </tbody>
//       </Table>
//     );
//   }
//   return <EmptyRecordingsList />;
// }
//
// RecordingsList.defaultProps = {
//   recordings: [],
//   recordingsProcessing: 0,
//   isLoading: false,
// };
//
// RecordingsList.propTypes = {
//   recordings: PropTypes.arrayOf(PropTypes.shape({
//     id: PropTypes.string.isRequired,
//     name: PropTypes.string.isRequired,
//     length: PropTypes.number.isRequired,
//     participants: PropTypes.number.isRequired,
//     visibility: PropTypes.string.isRequired,
//     created_at: PropTypes.string.isRequired,
//     map: PropTypes.func,
//   })),
//   recordingsProcessing: PropTypes.number,
//   isLoading: PropTypes.bool,
//   searchInput: PropTypes.string.isRequired,
//   RecordingRow: PropTypes.func.isRequired,
// };
