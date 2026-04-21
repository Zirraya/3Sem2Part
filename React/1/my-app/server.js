const jsonServer = require('json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

server.use(middlewares);
server.use(jsonServer.bodyParser);

// Задержка для имитации загрузки
server.use((req, res, next) => {
  setTimeout(next, 500);
});

// ЛОГИН
server.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  if (email === 'user@example.com' && password === 'password123') {
    res.json({
      user: {
        id: 1,
        email: 'user@example.com',
        firstName: 'Иван',
        lastName: 'Петров',
        role: 'user',
        createdAt: new Date().toISOString(),
      },
      token: 'fake-jwt-token-12345',
    });
  } else {
    res.status(401).json({ message: 'Invalid credentials' });
  }
});

// РЕГИСТРАЦИЯ
server.post('/api/auth/register', (req, res) => {
  const { email, password, firstName, lastName } = req.body;
  
  // Проверка существования пользователя
  const users = router.db.get('users').value();
  const existingUser = users.find((u) => u.email === email);
  
  if (existingUser) {
    return res.status(400).json({ message: 'User already exists' });
  }
  
  const newUser = {
    id: users.length + 1,
    email,
    password,
    firstName,
    lastName,
    role: 'user',
    createdAt: new Date().toISOString(),
  };
  
  router.db.get('users').push(newUser).write();
  
  res.json({
    user: {
      id: newUser.id,
      email: newUser.email,
      firstName: newUser.firstName,
      lastName: newUser.lastName,
      role: newUser.role,
      createdAt: newUser.createdAt,
    },
    token: 'fake-jwt-token-' + newUser.id,
  });
});

// Статистика для дашборда
server.get('/api/dashboard/stats', (req, res) => {
  res.json({
    totalPosts: 42,
    totalComments: 156,
    totalProducts: 23,
    lastLogin: new Date().toISOString(),
  });
});

server.use(router);

server.listen(3001, () => {
  console.log('JSON Server is running on port 3001');
});