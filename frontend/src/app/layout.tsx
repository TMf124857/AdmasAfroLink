import type { Metadata } from 'next'
import './globals.css'

// Use system fonts to avoid Google Fonts fetch issues in Docker
const fontClass = 'font-sans'

export const metadata: Metadata = {
  title: 'AdmasAfroLink - Belgian Students to Uganda Internships',
  description: 'Connecting Belgian university students with life-changing internship opportunities in Uganda',
  metadataBase: new URL('http://localhost:3000'),
  keywords: 'internships, Belgium, Uganda, students, cultural exchange, work placement',
  authors: [{ name: 'AdmasAfroLink Team' }],
  openGraph: {
    title: 'AdmasAfroLink - Belgian Students to Uganda Internships',
    description: 'Discover meaningful internship opportunities in Uganda for Belgian university students',
    url: 'http://localhost:3000',
    siteName: 'AdmasAfroLink',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'AdmasAfroLink - Belgian Students to Uganda Internships',
    description: 'Discover meaningful internship opportunities in Uganda for Belgian university students',
    images: ['/twitter-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'your-google-verification-code',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="font-sans antialiased">
        <div id="__next">
          {children}
        </div>
      </body>
    </html>
  )
}
