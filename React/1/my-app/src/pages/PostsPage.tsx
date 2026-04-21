import React, { useEffect, useState } from 'react';
import { Container, Typography, Box, Card, CardContent, IconButton, TextField, Dialog, DialogTitle, DialogContent, DialogActions } from '@mui/material';
import { Delete, Edit, Add } from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { RootState } from '../store/store';
import { getRequest, postRequest, putRequest, deleteRequest } from '../services/api';
import { setPosts, addPost, updatePost, deletePost } from '../store/slices/dataSlice';
import { CustomButton } from '../ui/CustomButton';
import { Button } from '@mui/material';

interface IPost {
  id: number;
  title: string;
  content: string;
  userId: number;
}

export const PostsPage: React.FC = () => {
  const dispatch = useDispatch();
  const { posts } = useSelector((state: RootState) => state.data);
  const [open, setOpen] = useState(false);
  const [editingPost, setEditingPost] = useState<IPost | null>(null);
  const [formData, setFormData] = useState({ title: '', content: '' });

  useEffect(() => {
    const fetchPosts = async () => {
      const data = await getRequest<IPost[]>('/posts');
      dispatch(setPosts(data));
    };
    fetchPosts();
  }, [dispatch]);

  const handleSave = async () => {
    if (editingPost) {
      const updated = await putRequest<IPost>(`/posts/${editingPost.id}`, formData);
      dispatch(updatePost(updated));
    } else {
      const created = await postRequest<IPost>('/posts', formData);
      dispatch(addPost(created));
    }
    handleClose();
  };

  const handleDelete = async (id: number) => {
    await deleteRequest(`/posts/${id}`);
    dispatch(deletePost(id));
  };

  const handleClose = () => {
    setOpen(false);
    setEditingPost(null);
    setFormData({ title: '', content: '' });
  };

  const handleEdit = (post: IPost) => {
    setEditingPost(post);
    setFormData({ title: post.title, content: post.content });
    setOpen(true);
  };

  return (
    <Container maxWidth="lg">
      <Box sx={{ my: 4 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
          <Typography variant="h4">Посты</Typography>
          <CustomButton
            variant="contained"
            startIcon={<Add />}
            onClick={() => setOpen(true)}
            tooltip="Создать новый пост"
          >
            Создать пост
          </CustomButton>
        </Box>

        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          {posts.map((post) => (
            <Card key={post.id}>
              <CardContent>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <Box>
                    <Typography variant="h6">{post.title}</Typography>
                    <Typography color="text.secondary" sx={{ mt: 1 }}>
                      {post.content}
                    </Typography>
                  </Box>
                  <Box>
                    <IconButton onClick={() => handleEdit(post)} color="primary">
                      <Edit />
                    </IconButton>
                    <IconButton onClick={() => handleDelete(post.id)} color="error">
                      <Delete />
                    </IconButton>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          ))}
        </Box>

        <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
          <DialogTitle>{editingPost ? 'Редактировать пост' : 'Создать пост'}</DialogTitle>
          <DialogContent>
            <TextField
              autoFocus
              margin="dense"
              label="Заголовок"
              fullWidth
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            />
            <TextField
              margin="dense"
              label="Содержание"
              fullWidth
              multiline
              rows={4}
              value={formData.content}
              onChange={(e) => setFormData({ ...formData, content: e.target.value })}
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={handleClose}>Отмена</Button>
            <Button onClick={handleSave} variant="contained">Сохранить</Button>
          </DialogActions>
        </Dialog>
      </Box>
    </Container>
  );
};