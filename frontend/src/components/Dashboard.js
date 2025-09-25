import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { taskAPI } from '../services/api';
import { toast } from 'react-toastify';
import TaskList from './TaskList';
import TaskForm from './TaskForm';
import TaskStats from './TaskStats';
import './Dashboard.css';

const Dashboard = () => {
  const [tasks, setTasks] = useState([]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [showTaskForm, setShowTaskForm] = useState(false);
  const [editingTask, setEditingTask] = useState(null);
  const [filters, setFilters] = useState({
    status: '',
    priority: '',
    sortBy: 'createdAt',
    sortOrder: 'DESC'
  });

  const { user, logout } = useAuth();

  useEffect(() => {
    fetchTasks();
    fetchStats();
  }, [filters]);

  const fetchTasks = async () => {
    try {
      setLoading(true);
      const response = await taskAPI.getTasks(filters);
      setTasks(response.data.tasks);
    } catch (error) {
      toast.error('Failed to fetch tasks');
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const response = await taskAPI.getStats();
      setStats(response.data);
    } catch (error) {
      console.error('Failed to fetch stats:', error);
    }
  };

  const handleCreateTask = async (taskData) => {
    try {
      const response = await taskAPI.createTask(taskData);
      setTasks(prev => [response.data.task, ...prev]);
      setShowTaskForm(false);
      toast.success('Task created successfully!');
      fetchStats(); // Refresh stats
    } catch (error) {
      toast.error(error.response?.data?.error || 'Failed to create task');
    }
  };

  const handleUpdateTask = async (taskData) => {
    try {
      const response = await taskAPI.updateTask(editingTask.id, taskData);
      setTasks(prev => prev.map(task => 
        task.id === editingTask.id ? response.data.task : task
      ));
      setEditingTask(null);
      toast.success('Task updated successfully!');
      fetchStats(); // Refresh stats
    } catch (error) {
      toast.error(error.response?.data?.error || 'Failed to update task');
    }
  };

  const handleDeleteTask = async (taskId) => {
    if (!window.confirm('Are you sure you want to delete this task?')) {
      return;
    }

    try {
      await taskAPI.deleteTask(taskId);
      setTasks(prev => prev.filter(task => task.id !== taskId));
      toast.success('Task deleted successfully!');
      fetchStats(); // Refresh stats
    } catch (error) {
      toast.error('Failed to delete task');
    }
  };

  const handleFilterChange = (filterType, value) => {
    setFilters(prev => ({
      ...prev,
      [filterType]: value
    }));
  };

  const handleEditTask = (task) => {
    setEditingTask(task);
    setShowTaskForm(true);
  };

  const closeTaskForm = () => {
    setShowTaskForm(false);
    setEditingTask(null);
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <div className="header-content">
          <div className="header-left">
            <h1>Task Manager</h1>
            <p>Welcome back, {user?.firstName || user?.username}!</p>
          </div>
          <div className="header-right">
            <button 
              className="btn btn-primary"
              onClick={() => setShowTaskForm(true)}
            >
              + New Task
            </button>
            <button className="btn btn-secondary" onClick={logout}>
              Logout
            </button>
          </div>
        </div>
      </header>

      <div className="dashboard-content">
        {stats && <TaskStats stats={stats} />}
        
        <div className="dashboard-main">
          <div className="filters">
            <select 
              value={filters.status} 
              onChange={(e) => handleFilterChange('status', e.target.value)}
            >
              <option value="">All Status</option>
              <option value="pending">Pending</option>
              <option value="in-progress">In Progress</option>
              <option value="completed">Completed</option>
            </select>

            <select 
              value={filters.priority} 
              onChange={(e) => handleFilterChange('priority', e.target.value)}
            >
              <option value="">All Priorities</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
            </select>

            <select 
              value={filters.sortBy} 
              onChange={(e) => handleFilterChange('sortBy', e.target.value)}
            >
              <option value="createdAt">Sort by Created</option>
              <option value="updatedAt">Sort by Updated</option>
              <option value="dueDate">Sort by Due Date</option>
              <option value="priority">Sort by Priority</option>
            </select>
          </div>

          <TaskList 
            tasks={tasks}
            loading={loading}
            onEdit={handleEditTask}
            onDelete={handleDeleteTask}
            onStatusChange={handleUpdateTask}
          />
        </div>
      </div>

      {showTaskForm && (
        <TaskForm
          task={editingTask}
          onSubmit={editingTask ? handleUpdateTask : handleCreateTask}
          onClose={closeTaskForm}
        />
      )}
    </div>
  );
};

export default Dashboard;