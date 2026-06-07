import { useSelector, useDispatch } from 'react-redux';
import { logout } from '../store/slices/authSlice';

export default function useAuth() {
  const dispatch = useDispatch();
  const { user, loading, error, initialized } = useSelector((s) => s.auth);
  const isAuthenticated = !!user && !!localStorage.getItem('token');

  return {
    user,
    loading,
    error,
    initialized,
    isAuthenticated,
    logout: () => dispatch(logout()),
    isPolice: user?.role === 'police' || user?.role === 'admin',
  };
}
