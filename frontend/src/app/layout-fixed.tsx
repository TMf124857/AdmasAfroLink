import type { Metadata } from 'next'
import React from 'react'
import './globals.css'

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
        {/* Use local fonts to avoid Google Fonts fetch issues in Docker */}
      </head>
      <body className="font-sans antialiased">
        <div id="__next">
          {children}
        </div>
      </body>
    </html>
  )
}
