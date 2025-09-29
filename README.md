# Task Manager - Full Stack Application

A full-stack task management application built with React, Node.js/Express, and PostgreSQL. This project demonstrates a complete web application with authentication, CRUD operations, and modern web development practices.

## 🏗️ Project Structure

```
task-manager/
├── backend/                 # Node.js/Express API
│   ├── src/
│   │   ├── config/         # Database configuration
│   │   ├── middleware/     # Auth & rate limiting middleware
│   │   ├── migrations/     # Database migrations
│   │   ├── models/         # Sequelize models
│   │   ├── routes/         # API routes
│   │   └── server.js       # Express server
│   ├── package.json
│   └── .env.example
└── frontend/               # React application
    ├── src/
    │   ├── components/     # React components
    │   ├── context/       # Auth context
    │   ├── services/      # API services
    │   └── App.js
    └── package.json
```

## 🚀 Features

### Backend (Node.js/Express)
- RESTful API with Express.js
- JWT-based authentication
- Password hashing with bcrypt
- PostgreSQL database with Sequelize ORM
- Input validation and error handling
- Rate limiting and security middleware
- CORS configuration

### Frontend (React)
- Modern React with hooks
- React Router for navigation
- Context API for state management
- Responsive design
- Real-time task management
- Toast notifications
- Protected routes

### Database Schema
- **Users Table**: id, username, email, password (hashed), firstName, lastName, timestamps
- **Tasks Table**: id, title, description, status, priority, dueDate, userId, timestamps

## 📋 Prerequisites

Before running this project, make sure you have:

- Node.js (v16 or higher)
- npm or yarn
- PostgreSQL (v12 or higher)
- Git

## 🛠️ Local Development Setup

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd task-manager
```

### 2. Database Setup

1. **Install PostgreSQL** (if not already installed):
   - Windows: Download from [postgresql.org](https://www.postgresql.org/download/windows/)
   - macOS: `brew install postgresql`
   - Linux: `sudo apt-get install postgresql postgresql-contrib`

2. **Start PostgreSQL service**:
   - Windows: Start from Services or pgAdmin
   - macOS: `brew services start postgresql`
   - Linux: `sudo systemctl start postgresql`

3. **Create database**:
   ```bash
   # Connect to PostgreSQL
   psql -U postgres
   
   # Create database
   CREATE DATABASE task_manager_db;
   
   # Exit psql
   \q
   ```

### 3. Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Environment Configuration**:
   ```bash
   # Copy example environment file
   cp .env.example .env
   
   # Edit .env file with your database credentials
   # Update the following variables:
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=task_manager_db
   DB_USER=postgres
   DB_PASS=your_postgres_password
   JWT_SECRET=your_very_long_and_secure_jwt_secret_key_here
   ```

4. **Run database migrations**:
   ```bash
   npm run db:migrate
   ```

5. **Start the backend server**:
   ```bash
   # Development mode (with auto-restart)
   npm run dev
   
   # Or production mode
   npm start
   ```

   The backend API will be available at `http://localhost:5000`

### 4. Frontend Setup

1. **Open a new terminal and navigate to frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Start the React development server**:
   ```bash
   npm start
   ```

   The frontend will be available at `http://localhost:3000`

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Tasks (Protected Routes)
- `GET /api/tasks` - Get all tasks for authenticated user
- `GET /api/tasks/:id` - Get specific task
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `GET /api/tasks/stats/summary` - Get task statistics

## 📱 Using the Application

1. **Register/Login**: Create an account or login with existing credentials
2. **Dashboard**: View task statistics and manage tasks
3. **Create Tasks**: Click "New Task" to add tasks with title, description, priority, and due date
4. **Manage Tasks**: Edit, delete, or change status of existing tasks
5. **Filter Tasks**: Filter by status, priority, or sort by different criteria

## 🧪 Testing the API

You can test the API endpoints using tools like Postman or curl:

```bash
# Register a new user
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"test@example.com","password":"password123"}'

# Create a task (replace YOUR_JWT_TOKEN with actual token)
curl -X POST http://localhost:5000/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"title":"My First Task","description":"Task description","priority":"high"}'
```

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Error**:
   - Ensure PostgreSQL is running
   - Check database credentials in `.env`
   - Verify database exists

2. **Port Already in Use**:
   - Change PORT in backend `.env` file
   - Or kill process using the port: `npx kill-port 5000`

3. **CORS Errors**:
   - Ensure frontend URL is correctly set in backend CORS configuration
   - Check FRONTEND_URL in `.env`

4. **JWT Token Issues**:
   - Ensure JWT_SECRET is set in `.env`
   - Token expires after 7 days by default

### Database Reset

If you need to reset the database:

```bash
cd backend
npx sequelize-cli db:drop
npx sequelize-cli db:create
npm run db:migrate
```

## 📦 Project Dependencies

### Backend
- express - Web framework
- sequelize - ORM
- pg - PostgreSQL client
- bcrypt - Password hashing
- jsonwebtoken - JWT authentication
- cors - CORS middleware
- helmet - Security middleware
- express-rate-limit - Rate limiting

### Frontend
- react - UI library
- react-router-dom - Routing
- axios - HTTP client
- react-toastify - Notifications

## 🔒 Security Features

- Password hashing with bcrypt
- JWT token authentication
- Rate limiting on API endpoints
- Input validation
- CORS protection
- Security headers with Helmet
- Protected routes in frontend

## 📈 Performance Considerations

- Database indexing on frequently queried fields
- Pagination for task lists
- Request rate limiting
- Optimized SQL queries with Sequelize
- Frontend code splitting (can be added)

---

## 🚀 AWS Deployment

This application can be deployed to AWS using the free tier. See the [deployment guide](./deploy/README.md) for detailed instructions.

### Quick Deployment Options

1. **Automated Deployment** (Recommended):
   ```bash
   chmod +x deploy/quick-deploy.sh
   ./deploy/quick-deploy.sh
   ```

2. **Manual Deployment**:
   - Follow the [comprehensive guide](./deploy/DEPLOYMENT_GUIDE.md)
   - Use individual deployment scripts in the `deploy/` directory

3. **Docker Deployment**:
   ```bash
   docker-compose up -d
   ```

### AWS Infrastructure Required
- **EC2 Instance** (t2.micro) - Backend hosting
- **RDS PostgreSQL** (db.t3.micro) - Database
- **S3 Bucket** - Frontend hosting
- **CloudFront** - CDN and SSL

### Deployment Features
- ✅ Automated setup scripts
- ✅ Production environment configuration
- ✅ SSL certificate support
- ✅ PM2 process management
- ✅ Nginx reverse proxy
- ✅ Database migrations
- ✅ Health checks and monitoring
- ✅ Cost optimization for free tier

## 🐳 Docker Development

For local development with Docker:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📊 Monitoring

### Local Development
- Backend: `http://localhost:5000/health`
- Frontend: `http://localhost:3000`

### Production (AWS)
- Backend: `http://your-ec2-ip/health`
- Frontend: `https://your-domain.com`

---

## Local Development

This application is configured to run locally. Make sure you have:
- Node.js installed
- PostgreSQL database running locally
- Environment variables configured in your `.env` file