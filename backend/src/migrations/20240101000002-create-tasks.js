'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('tasks', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      title: {
        type: Sequelize.STRING(200),
        allowNull: false
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true
      },
      status: {
        type: Sequelize.ENUM('pending', 'in-progress', 'completed'),
        defaultValue: 'pending',
        allowNull: false
      },
      priority: {
        type: Sequelize.ENUM('low', 'medium', 'high'),
        defaultValue: 'medium',
        allowNull: false
      },
      dueDate: {
        type: Sequelize.DATE,
        allowNull: true
      },
      userId: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
      }
    });

    // Add indexes
    await queryInterface.addIndex('tasks', ['userId']);
    await queryInterface.addIndex('tasks', ['status']);
    await queryInterface.addIndex('tasks', ['dueDate']);
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('tasks');
  }
};