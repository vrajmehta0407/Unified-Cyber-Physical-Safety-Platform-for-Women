import { Routes, Route, Navigate } from 'react-router-dom';
import { useEffect } from 'react';
import { useDispatch } from 'react-redux';
import LoginPage from './pages/auth/LoginPage';
import PoliceDashboard from './pages/police/PoliceDashboard';
import ActiveSOSPage from './pages/police/ActiveSOSPage';
import IncidentListPage from './pages/police/IncidentListPage';
import IncidentDetailPage from './pages/police/IncidentDetailPage';
import EvidenceReviewPage from './pages/police/EvidenceReviewPage';
import CctnsIntegrationPage from './pages/police/CctnsIntegrationPage';
import ErssIntegrationPage from './pages/police/ErssIntegrationPage';
import UnsafeZoneMapPage from './pages/police/UnsafeZoneMapPage';
import ComplaintManagementPage from './pages/police/ComplaintManagementPage';
import AnalyticsPage from './pages/police/AnalyticsPage';
import BroadcastPage from './pages/police/BroadcastPage';
import FirGeneratorPage from './pages/police/FirGeneratorPage';
import OfficerManagementPage from './pages/police/OfficerManagementPage';
import AdminDashboard from './pages/admin/AdminDashboard';
import UserManagementPage from './pages/admin/UserManagementPage';
import SystemAnalyticsPage from './pages/admin/SystemAnalyticsPage';
import ContentManagementPage from './pages/admin/ContentManagementPage';
import PageLayout from './components/layout/PageLayout';
import ProtectedRoute from './components/auth/ProtectedRoute';
import { restoreSession, setInitialized } from './store/slices/authSlice';

export default function App() {
  const dispatch = useDispatch();

  useEffect(() => {
    if (localStorage.getItem('token')) {
      dispatch(restoreSession());
    } else {
      dispatch(setInitialized());
    }
  }, [dispatch]);

  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/"
        element={
          <ProtectedRoute roles={['police', 'admin']}>
            <PageLayout />
          </ProtectedRoute>
        }
      >
        {/* Police routes */}
        <Route index element={<PoliceDashboard />} />
        <Route path="sos" element={<ActiveSOSPage />} />
        <Route path="incidents" element={<IncidentListPage />} />
        <Route path="incidents/:id" element={<IncidentDetailPage />} />
        <Route path="complaints" element={<ComplaintManagementPage />} />
        <Route path="evidence" element={<EvidenceReviewPage />} />
        <Route path="zones" element={<UnsafeZoneMapPage />} />
        <Route path="cctns" element={<CctnsIntegrationPage />} />
        <Route path="erss" element={<ErssIntegrationPage />} />
        <Route path="analytics" element={<AnalyticsPage />} />
        <Route path="broadcast" element={<BroadcastPage />} />
        <Route path="fir" element={<FirGeneratorPage />} />
        <Route path="officers" element={<OfficerManagementPage />} />

        {/* Admin routes */}
        <Route path="admin" element={<AdminDashboard />} />
        <Route path="admin/users" element={<UserManagementPage />} />
        <Route path="admin/system" element={<SystemAnalyticsPage />} />
        <Route path="admin/content" element={<ContentManagementPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
