# AdmasAfroLink Frontend Setup Guide

## Prerequisites Installation

You can run the AdmasAfroLink frontend in two ways:

### Option 1: Using Docker (Recommended)
- Install [Docker Desktop](https://docker.com/get-started/) for Windows
- Start Docker Desktop and wait for it to fully load
- Verify installation: `docker --version`

### Option 2: Using Node.js directly
- Visit [Node.js official website](https://nodejs.org/)
- Download the LTS version (recommended)
- Run the installer and follow the installation wizard
- Verify installation by opening a new terminal and running:
  ```bash
  node --version
  npm --version
  ```

### Additional Requirements
- Git (if not already installed)
  - Visit [Git official website](https://git-scm.com/)
  - Download and install Git for Windows
  - Verify installation: `git --version`

## Project Setup Instructions

### Quick Start with Docker (Recommended)

1. **Start Docker Desktop** and wait for it to fully load

2. **Quick Start Script**
   ```bash
   .\quick-start.bat
   ```
   This will automatically:
   - Pull the Node.js Docker image
   - Install dependencies
   - Start the development server
   - Open the app at http://localhost:3000

3. **Alternative: Full Docker Setup**
   ```bash
   .\setup-docker.bat  # Initial setup
   .\docker-run.bat    # Management interface
   ```

### Traditional Setup (Node.js required)

Once you have Node.js and npm installed:

### 1. Navigate to the project directory
```bash
cd "c:\Users\Lenovo\Desktop\AdmasAfroLink\AdmasAfroLink\frontend"
```

### 2. Install dependencies
```bash
npm install
```

### 3. Run the development server
```bash
npm run dev
```

### 4. Open your browser
Navigate to `http://localhost:3000` to see the application.

## Project Structure

```
frontend/
├── src/
│   ├── app/                    # Next.js 14 app directory
│   │   ├── layout.tsx         # Root layout component
│   │   ├── page.tsx           # Home page
│   │   └── globals.css        # Global styles
│   ├── components/            # Reusable React components
│   │   ├── dashboard/         # Dashboard-related components
│   │   ├── auth/              # Authentication components
│   │   ├── forms/             # Form components
│   │   └── ui/                # UI components
│   ├── services/              # API service layer
│   │   └── api.ts             # API client configuration
│   ├── types/                 # TypeScript type definitions
│   │   └── index.ts           # Application types
│   └── utils/                 # Utility functions
│       └── index.ts           # Helper functions
├── public/                    # Static assets
├── package.json               # Dependencies and scripts
├── tsconfig.json             # TypeScript configuration
├── next.config.js            # Next.js configuration
└── README.md                 # This file
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run type-check` - Run TypeScript compiler

## Key Features

### 1. Student Dashboard
- Progress tracking through 16-stage internship workflow
- Real-time notifications
- Document management
- Application status monitoring

### 2. Cultural Integration
- Belgian Blue (#003366) and Uganda Gold (#FCDC00) theme
- English/French language support
- Cultural adaptation resources

### 3. Responsive Design
- Mobile-first approach
- Touch-friendly interface
- Accessibility features

### 4. Security Features
- Authentication integration
- Secure file uploads
- Data encryption

## Configuration

### Environment Variables
Create a `.env.local` file in the root directory:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
NEXT_PUBLIC_SOCKET_URL=http://localhost:8000
NEXT_PUBLIC_APP_NAME=AdmasAfroLink
NEXT_PUBLIC_APP_VERSION=1.0.0
```

### API Integration
The frontend is configured to work with a REST API backend. Update the API URLs in `src/services/api.ts` to match your backend configuration.

## Development Guidelines

### 1. Code Style
- Use TypeScript for all components
- Follow React best practices
- Use Material-UI components when possible
- Maintain consistent naming conventions

### 2. Component Structure
```typescript
// Component template
import React from 'react';
import { Box, Typography } from '@mui/material';

interface ComponentProps {
  // Define props here
}

const ComponentName: React.FC<ComponentProps> = ({ props }) => {
  return (
    <Box>
      <Typography variant="h4">Component Content</Typography>
    </Box>
  );
};

export default ComponentName;
```

### 3. State Management
- Use React Query for server state
- Use React hooks for local state
- Implement proper error handling

## Deployment

### Vercel (Recommended)
1. Connect your GitHub repository to Vercel
2. Configure environment variables
3. Deploy automatically on push to main branch

### Other Platforms
- Netlify
- AWS Amplify
- Digital Ocean App Platform

## Troubleshooting

### Common Issues

1. **TypeScript errors**: Ensure all dependencies are installed
2. **Module not found**: Check import paths and file extensions
3. **Build failures**: Verify environment variables and API endpoints

### Getting Help
- Check the [Next.js documentation](https://nextjs.org/docs)
- Review [Material-UI documentation](https://mui.com/)
- Create an issue in the project repository

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
