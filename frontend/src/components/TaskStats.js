import React from 'react';
import './TaskStats.css';

const TaskStats = ({ stats }) => {
  const getStatusCount = (status) => {
    const statusStat = stats.statusStats.find(s => s.status === status);
    return statusStat ? statusStat.count : 0;
  };

  const getPriorityCount = (priority) => {
    const priorityStat = stats.priorityStats.find(p => p.priority === priority);
    return priorityStat ? priorityStat.count : 0;
  };

  const totalTasks = stats.statusStats.reduce((sum, stat) => sum + parseInt(stat.count), 0);

  return (
    <div className="task-stats">
      <h3>Task Overview</h3>
      
      <div className="stats-grid">
        <div className="stat-card total">
          <h4>Total Tasks</h4>
          <span className="stat-number">{totalTasks}</span>
        </div>

        <div className="stat-card pending">
          <h4>Pending</h4>
          <span className="stat-number">{getStatusCount('pending')}</span>
        </div>

        <div className="stat-card in-progress">
          <h4>In Progress</h4>
          <span className="stat-number">{getStatusCount('in-progress')}</span>
        </div>

        <div className="stat-card completed">
          <h4>Completed</h4>
          <span className="stat-number">{getStatusCount('completed')}</span>
        </div>

        {stats.overdueCount > 0 && (
          <div className="stat-card overdue">
            <h4>Overdue</h4>
            <span className="stat-number">{stats.overdueCount}</span>
          </div>
        )}
      </div>

      <div className="priority-stats">
        <h4>By Priority</h4>
        <div className="priority-grid">
          <div className="priority-item high">
            <span>High: {getPriorityCount('high')}</span>
          </div>
          <div className="priority-item medium">
            <span>Medium: {getPriorityCount('medium')}</span>
          </div>
          <div className="priority-item low">
            <span>Low: {getPriorityCount('low')}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TaskStats;