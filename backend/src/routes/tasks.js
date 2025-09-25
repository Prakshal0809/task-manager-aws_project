const express = require('express');
const { Task, User } = require('../models');
const authMiddleware = require('../middleware/auth');
const { Op } = require('sequelize');

const router = express.Router();

// Apply auth middleware to all routes
router.use(authMiddleware);

// Get all tasks for the authenticated user
router.get('/', async (req, res) => {
  try {
    const {
      status,
      priority,
      sortBy = 'createdAt',
      sortOrder = 'DESC',
      page = 1,
      limit = 10
    } = req.query;

    const whereClause = { userId: req.user.id };

    // Add filters
    if (status) {
      whereClause.status = status;
    }
    if (priority) {
      whereClause.priority = priority;
    }

    // Calculate pagination
    const offset = (parseInt(page) - 1) * parseInt(limit);

    const tasks = await Task.findAndCountAll({
      where: whereClause,
      order: [[sortBy, sortOrder.toUpperCase()]],
      limit: parseInt(limit),
      offset: offset,
      include: [{
        model: User,
        as: 'user',
        attributes: ['username', 'firstName', 'lastName']
      }]
    });

    res.json({
      tasks: tasks.rows,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(tasks.count / parseInt(limit)),
        totalTasks: tasks.count,
        hasNext: offset + parseInt(limit) < tasks.count,
        hasPrev: parseInt(page) > 1
      }
    });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({
      error: 'Failed to retrieve tasks.'
    });
  }
});

// Get a single task by ID
router.get('/:id', async (req, res) => {
  try {
    const task = await Task.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      },
      include: [{
        model: User,
        as: 'user',
        attributes: ['username', 'firstName', 'lastName']
      }]
    });

    if (!task) {
      return res.status(404).json({
        error: 'Task not found.'
      });
    }

    res.json(task);
  } catch (error) {
    console.error('Get task error:', error);
    res.status(500).json({
      error: 'Failed to retrieve task.'
    });
  }
});

// Create a new task
router.post('/', async (req, res) => {
  try {
    const { title, description, status, priority, dueDate } = req.body;

    // Basic validation
    if (!title || title.trim().length === 0) {
      return res.status(400).json({
        error: 'Task title is required.'
      });
    }

    const taskData = {
      title: title.trim(),
      description: description?.trim() || null,
      userId: req.user.id
    };

    // Add optional fields if provided
    if (status && ['pending', 'in-progress', 'completed'].includes(status)) {
      taskData.status = status;
    }

    if (priority && ['low', 'medium', 'high'].includes(priority)) {
      taskData.priority = priority;
    }

    if (dueDate) {
      const parsedDate = new Date(dueDate);
      if (!isNaN(parsedDate.getTime())) {
        taskData.dueDate = parsedDate;
      }
    }

    const task = await Task.create(taskData);

    // Fetch the created task with user info
    const createdTask = await Task.findByPk(task.id, {
      include: [{
        model: User,
        as: 'user',
        attributes: ['username', 'firstName', 'lastName']
      }]
    });

    res.status(201).json({
      message: 'Task created successfully.',
      task: createdTask
    });
  } catch (error) {
    console.error('Create task error:', error);
    
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        error: error.errors.map(err => err.message).join(', ')
      });
    }

    res.status(500).json({
      error: 'Failed to create task.'
    });
  }
});

// Update a task
router.put('/:id', async (req, res) => {
  try {
    const { title, description, status, priority, dueDate } = req.body;

    const task = await Task.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!task) {
      return res.status(404).json({
        error: 'Task not found.'
      });
    }

    const updateData = {};

    // Update only provided fields
    if (title !== undefined) {
      if (!title || title.trim().length === 0) {
        return res.status(400).json({
          error: 'Task title cannot be empty.'
        });
      }
      updateData.title = title.trim();
    }

    if (description !== undefined) {
      updateData.description = description?.trim() || null;
    }

    if (status && ['pending', 'in-progress', 'completed'].includes(status)) {
      updateData.status = status;
    }

    if (priority && ['low', 'medium', 'high'].includes(priority)) {
      updateData.priority = priority;
    }

    if (dueDate !== undefined) {
      if (dueDate === null || dueDate === '') {
        updateData.dueDate = null;
      } else {
        const parsedDate = new Date(dueDate);
        if (!isNaN(parsedDate.getTime())) {
          updateData.dueDate = parsedDate;
        } else {
          return res.status(400).json({
            error: 'Invalid due date format.'
          });
        }
      }
    }

    await task.update(updateData);

    // Fetch updated task with user info
    const updatedTask = await Task.findByPk(task.id, {
      include: [{
        model: User,
        as: 'user',
        attributes: ['username', 'firstName', 'lastName']
      }]
    });

    res.json({
      message: 'Task updated successfully.',
      task: updatedTask
    });
  } catch (error) {
    console.error('Update task error:', error);
    
    if (error.name === 'SequelizeValidationError') {
      return res.status(400).json({
        error: error.errors.map(err => err.message).join(', ')
      });
    }

    res.status(500).json({
      error: 'Failed to update task.'
    });
  }
});

// Delete a task
router.delete('/:id', async (req, res) => {
  try {
    const task = await Task.findOne({
      where: {
        id: req.params.id,
        userId: req.user.id
      }
    });

    if (!task) {
      return res.status(404).json({
        error: 'Task not found.'
      });
    }

    await task.destroy();

    res.json({
      message: 'Task deleted successfully.'
    });
  } catch (error) {
    console.error('Delete task error:', error);
    res.status(500).json({
      error: 'Failed to delete task.'
    });
  }
});

// Get task statistics for the user
router.get('/stats/summary', async (req, res) => {
  try {
    const userId = req.user.id;

    const stats = await Task.findAll({
      where: { userId },
      attributes: [
        'status',
        [Task.sequelize.fn('COUNT', Task.sequelize.col('status')), 'count']
      ],
      group: ['status'],
      raw: true
    });

    const priorityStats = await Task.findAll({
      where: { userId },
      attributes: [
        'priority',
        [Task.sequelize.fn('COUNT', Task.sequelize.col('priority')), 'count']
      ],
      group: ['priority'],
      raw: true
    });

    // Get overdue tasks count
    const overdueCount = await Task.count({
      where: {
        userId,
        dueDate: {
          [Op.lt]: new Date()
        },
        status: {
          [Op.ne]: 'completed'
        }
      }
    });

    res.json({
      statusStats: stats,
      priorityStats: priorityStats,
      overdueCount
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      error: 'Failed to retrieve task statistics.'
    });
  }
});

module.exports = router;