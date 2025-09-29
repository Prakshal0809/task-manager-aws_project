import React from 'react';
import './TaskList.css';

const TaskList = ({ tasks, loading, onEdit, onDelete, onStatusChange }) => {
  const formatDate = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString();
  };

  // Removed unused functions to fix ESLint warnings

  const handleStatusChange = (task, newStatus) => {
    onStatusChange({ ...task, status: newStatus });
  };

  if (loading) {
    return <div className="loading">Loading tasks...</div>;
  }

  if (tasks.length === 0) {
    return (
      <div className="no-tasks">
        <h3>No tasks found</h3>
        <p>Create your first task to get started!</p>
      </div>
    );
  }

  return (
    <div className="task-list">
      <h3>Your Tasks ({tasks.length})</h3>
      
      <div className="tasks-grid">
        {tasks.map(task => (
          <div key={task.id} className="task-card">
            <div className="task-header">
              <h4 className="task-title">{task.title}</h4>
              <div className="task-badges">
                <span className={`badge status ${task.status}`}>
                  {task.status.replace('-', ' ')}
                </span>
                <span className={`badge priority ${task.priority}`}>
                  {task.priority}
                </span>
              </div>
            </div>

            {task.description && (
              <p className="task-description">{task.description}</p>
            )}

            <div className="task-meta">
              <div className="task-dates">
                <small>Created: {formatDate(task.createdAt)}</small>
                {task.dueDate && (
                  <small>Due: {formatDate(task.dueDate)}</small>
                )}
              </div>
            </div>

            <div className="task-actions">
              <select
                value={task.status}
                onChange={(e) => handleStatusChange(task, e.target.value)}
                className="status-select"
              >
                <option value="pending">Pending</option>
                <option value="in-progress">In Progress</option>
                <option value="completed">Completed</option>
              </select>

              <div className="action-buttons">
                <button
                  className="btn btn-sm btn-secondary"
                  onClick={() => onEdit(task)}
                >
                  Edit
                </button>
                <button
                  className="btn btn-sm btn-danger"
                  onClick={() => onDelete(task.id)}
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default TaskList;