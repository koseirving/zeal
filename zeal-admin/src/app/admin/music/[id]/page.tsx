'use client';

import { useState, useEffect, use } from 'react';
import { useRouter } from 'next/navigation';
import { doc, getDoc, addDoc, updateDoc, collection } from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { db, storage, auth } from '../../../../../lib/firebase';
import { Music } from '../../../../../lib/types';
import AuthGuard from '../../../../../components/AuthGuard';
import Layout from '../../../../../components/Layout';

export default function MusicEditPage({ params }: { params: Promise<{ id: string }> }) {
  const router = useRouter();
  const resolvedParams = use(params);
  const isNew = resolvedParams.id === 'new';
  
  const [music, setMusic] = useState<Partial<Music>>({
    title: '',
    artist: '',
    audioUrl: '',
    category: '',
    duration: 0,
    isActive: true,
    playCount: 0,
    tags: []
  });
  const [loading, setLoading] = useState(!isNew);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [audioFile, setAudioFile] = useState<File | null>(null);
  const [imageFile, setImageFile] = useState<File | null>(null);

  useEffect(() => {
    if (!isNew) {
      loadMusic();
    }
  }, [isNew, resolvedParams.id]);

  const loadMusic = async () => {
    try {
      const docRef = doc(db, 'music', resolvedParams.id);
      const docSnap = await getDoc(docRef);
      
      if (docSnap.exists()) {
        setMusic({ id: docSnap.id, ...docSnap.data() } as Music);
      } else {
        alert('音楽が見つかりません');
        router.push('/admin');
      }
    } catch (error) {
      console.error('Error loading music:', error);
      alert('読み込みに失敗しました');
    } finally {
      setLoading(false);
    }
  };

  const uploadFile = async (file: File, path: string): Promise<string> => {
    console.log(`Starting upload for file: ${file.name}, Path: ${path}`);
    
    try {
      const storageRef = ref(storage, path);
      console.log('Storage reference created:', storageRef);
      
      const snapshot = await uploadBytes(storageRef, file);
      console.log('File uploaded successfully, getting download URL...');
      
      const downloadUrl = await getDownloadURL(snapshot.ref);
      console.log('Download URL obtained:', downloadUrl);
      
      return downloadUrl;
    } catch (error) {
      console.error('Upload error details:', error);
      throw error;
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setUploading(true);

    try {
      console.log('Starting music save process...');
      
      // Check authentication status
      const user = auth.currentUser;
      console.log('Current user:', user);
      console.log('User authenticated:', !!user);
      if (user) {
        console.log('User ID:', user.uid);
        console.log('User email:', user.email);
      }
      
      let audioUrl = music.audioUrl;
      let imageUrl = music.imageUrl;

      // Audio file upload
      if (audioFile) {
        console.log('Uploading audio file:', audioFile.name, 'Size:', audioFile.size);
        const audioPath = `music/audio/${Date.now()}_${audioFile.name}`;
        try {
          audioUrl = await uploadFile(audioFile, audioPath);
          console.log('Audio file uploaded successfully:', audioUrl);
        } catch (uploadError) {
          console.error('Audio upload failed:', uploadError);
          throw new Error(`音楽ファイルのアップロードに失敗しました: ${uploadError instanceof Error ? uploadError.message : 'Unknown error'}`);
        }
      }

      // Image file upload
      if (imageFile) {
        console.log('Uploading image file:', imageFile.name, 'Size:', imageFile.size);
        const imagePath = `music/images/${Date.now()}_${imageFile.name}`;
        try {
          imageUrl = await uploadFile(imageFile, imagePath);
          console.log('Image file uploaded successfully:', imageUrl);
        } catch (uploadError) {
          console.error('Image upload failed:', uploadError);
          throw new Error(`画像ファイルのアップロードに失敗しました: ${uploadError instanceof Error ? uploadError.message : 'Unknown error'}`);
        }
      }

      // Prepare data for Firestore
      const data = {
        ...music,
        audioUrl,
        ...(imageUrl && { imageUrl }),
        updatedAt: new Date(),
        ...(isNew && { createdAt: new Date() })
      };

      console.log('Saving data to Firestore:', data);

      // Save to Firestore
      if (isNew) {
        const docRef = await addDoc(collection(db, 'music'), data);
        console.log('New music document created with ID:', docRef.id);
      } else {
        await updateDoc(doc(db, 'music', resolvedParams.id), data);
        console.log('Music document updated:', resolvedParams.id);
      }

      console.log('Save completed successfully, redirecting...');
      router.push('/admin');
    } catch (error) {
      console.error('Error saving music:', error);
      const errorMessage = error instanceof Error ? error.message : '不明なエラーが発生しました';
      alert(`保存に失敗しました: ${errorMessage}`);
    } finally {
      setSaving(false);
      setUploading(false);
    }
  };

  const handleChange = (field: keyof Music, value: any) => {
    setMusic(prev => ({ ...prev, [field]: value }));
  };

  const handleAudioFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setAudioFile(file);
      
      const audio = document.createElement('audio');
      audio.onloadedmetadata = () => {
        setMusic(prev => ({ ...prev, duration: Math.floor(audio.duration) }));
      };
      audio.src = URL.createObjectURL(file);
    }
  };

  const handleImageFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setImageFile(file);
    }
  };

  if (loading) {
    return (
      <AuthGuard>
        <Layout>
          <div className="flex items-center justify-center h-64">
            <div className="text-gray-400">読み込み中...</div>
          </div>
        </Layout>
      </AuthGuard>
    );
  }

  return (
    <AuthGuard>
      <Layout>
        <div className="max-w-2xl mx-auto">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-white">
              {isNew ? '音楽新規作成' : '音楽編集'}
            </h1>
          </div>

          <form onSubmit={handleSubmit} className="bg-gray-800 rounded-lg p-6 space-y-6">
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-300 mb-2">
                タイトル *
              </label>
              <input
                id="title"
                type="text"
                value={music.title || ''}
                onChange={(e) => handleChange('title', e.target.value)}
                required
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="音楽のタイトルを入力してください"
              />
            </div>

            <div>
              <label htmlFor="artist" className="block text-sm font-medium text-gray-300 mb-2">
                アーティスト *
              </label>
              <input
                id="artist"
                type="text"
                value={music.artist || ''}
                onChange={(e) => handleChange('artist', e.target.value)}
                required
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="アーティスト名を入力してください"
              />
            </div>

            <div>
              <label htmlFor="category" className="block text-sm font-medium text-gray-300 mb-2">
                カテゴリ *
              </label>
              <select
                id="category"
                value={music.category || ''}
                onChange={(e) => handleChange('category', e.target.value)}
                required
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">カテゴリを選択してください</option>
                <option value="Focus">集中</option>
                <option value="Meditation">瞑想</option>
                <option value="Nature">自然</option>
                <option value="Sleep">睡眠</option>
                <option value="Energy">エネルギー</option>
                <option value="Relaxation">リラクゼーション</option>
              </select>
            </div>

            <div>
              <label htmlFor="audioFile" className="block text-sm font-medium text-gray-300 mb-2">
                音楽ファイル {!isNew && music.audioUrl && '(現在のファイルを置き換える場合のみ選択)'}
              </label>
              <input
                id="audioFile"
                type="file"
                accept="audio/*"
                onChange={handleAudioFileChange}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-600 file:text-white hover:file:bg-blue-700"
              />
              {music.audioUrl && !audioFile && (
                <p className="text-xs text-gray-400 mt-1">
                  現在のファイル: {music.audioUrl.split('/').pop()}
                </p>
              )}
            </div>

            <div>
              <label htmlFor="imageFile" className="block text-sm font-medium text-gray-300 mb-2">
                画像ファイル（オプション）
              </label>
              <input
                id="imageFile"
                type="file"
                accept="image/*"
                onChange={handleImageFileChange}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-blue-600 file:text-white hover:file:bg-blue-700"
              />
              {music.imageUrl && !imageFile && (
                <p className="text-xs text-gray-400 mt-1">
                  現在の画像: {music.imageUrl.split('/').pop()}
                </p>
              )}
            </div>

            <div>
              <label htmlFor="duration" className="block text-sm font-medium text-gray-300 mb-2">
                再生時間（秒）
              </label>
              <input
                id="duration"
                type="number"
                value={music.duration || 0}
                onChange={(e) => handleChange('duration', parseInt(e.target.value))}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="再生時間を秒で入力（ファイル選択時に自動設定されます）"
              />
            </div>

            <div>
              <label htmlFor="tags" className="block text-sm font-medium text-gray-300 mb-2">
                タグ（カンマ区切り）
              </label>
              <input
                id="tags"
                type="text"
                value={music.tags?.join(', ') || ''}
                onChange={(e) => handleChange('tags', e.target.value.split(',').map(tag => tag.trim()).filter(tag => tag))}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="例: ヒーリング, インストゥルメンタル, アンビエント"
              />
            </div>

            <div className="flex items-center">
              <input
                id="isActive"
                type="checkbox"
                checked={music.isActive || false}
                onChange={(e) => handleChange('isActive', e.target.checked)}
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              />
              <label htmlFor="isActive" className="ml-2 block text-sm text-gray-300">
                有効にする
              </label>
            </div>

            <div className="flex justify-end space-x-4">
              <button
                type="button"
                onClick={() => router.push('/admin')}
                className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-md transition duration-200"
              >
                キャンセル
              </button>
              <button
                type="submit"
                disabled={saving || uploading}
                className="px-4 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-800 disabled:cursor-not-allowed text-white rounded-md transition duration-200"
              >
                {uploading ? 'アップロード中...' : saving ? '保存中...' : '保存'}
              </button>
            </div>
          </form>
        </div>
      </Layout>
    </AuthGuard>
  );
}