export interface Affirmation {
  id?: string;
  text: string;
  category: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  viewCount?: number;
  createdBy?: string;
  tags?: string[];
}

export interface Music {
  id?: string;
  title: string;
  artist: string;
  audioUrl: string;
  category: string;
  duration: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  imageUrl?: string;
  playCount?: number;
  createdBy?: string;
  tags?: string[];
}

export interface Video {
  id?: string;
  title: string;
  description: string;
  videoUrl: string;
  thumbnailUrl: string;
  category: string;
  likes: number;
  views: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  createdBy?: string;
  tags?: string[];
}

export type ContentType = 'affirmations' | 'music' | 'videos';

export interface User {
  uid: string;
  email: string;
  isAdmin?: boolean;
}