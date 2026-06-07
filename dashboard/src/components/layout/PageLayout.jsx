import { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { NavLink, Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Navbar from './Navbar';
import { fetchActiveSos } from '../../store/slices/sosSlice';
import './PageLayout.css';

export default function PageLayout() {
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(fetchActiveSos());
    const interval = setInterval(() => dispatch(fetchActiveSos()), 20000);
    return () => clearInterval(interval);
  }, [dispatch]);

  return (
    <div className="page-layout">
      <Sidebar />
      <div className="main-content">
        <Navbar />
        <main className="page-body">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
