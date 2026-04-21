import React, { useEffect, useState } from 'react';
import {
  Container,
  Typography,
  Box,
  Card,
  CardContent,
  IconButton,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button
} from '@mui/material';
import { Delete, Edit, Add } from '@mui/icons-material';
import { useDispatch, useSelector } from 'react-redux';
import { RootState } from '../store/store';
import { getRequest, postRequest, putRequest, deleteRequest } from '../services/api';
import { setProducts, addProduct, updateProduct, deleteProduct } from '../store/slices/dataSlice';
import { CustomButton } from '../ui/CustomButton';

interface IProduct {
  id: number;
  name: string;
  price: number;
  description: string;
}

export const ProductsPage: React.FC = () => {
  const dispatch = useDispatch();
  const { products } = useSelector((state: RootState) => state.data);
  const [open, setOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<IProduct | null>(null);
  const [formData, setFormData] = useState({ name: '', price: 0, description: '' });

  useEffect(() => {
    const fetchProducts = async () => {
      const data = await getRequest<IProduct[]>('/products');
      dispatch(setProducts(data));
    };
    fetchProducts();
  }, [dispatch]);

  const handleSave = async () => {
    if (editingProduct) {
      const updated = await putRequest<IProduct>(`/products/${editingProduct.id}`, formData);
      dispatch(updateProduct(updated));
    } else {
      const created = await postRequest<IProduct>('/products', formData);
      dispatch(addProduct(created));
    }
    handleClose();
  };

  const handleDelete = async (id: number) => {
    await deleteRequest(`/products/${id}`);
    dispatch(deleteProduct(id));
  };

  const handleClose = () => {
    setOpen(false);
    setEditingProduct(null);
    setFormData({ name: '', price: 0, description: '' });
  };

  const handleEdit = (product: IProduct) => {
    setEditingProduct(product);
    setFormData({ name: product.name, price: product.price, description: product.description });
    setOpen(true);
  };

  return (
    <Container maxWidth="lg">
      <Box sx={{ my: 4 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
          <Typography variant="h4">Товары</Typography>
          <CustomButton
            variant="contained"
            startIcon={<Add />}
            onClick={() => setOpen(true)}
            tooltip="Добавить новый товар"
          >
            Добавить товар
          </CustomButton>
        </Box>

        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          {products.map((product) => (
            <Card key={product.id}>
              <CardContent>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <Box>
                    <Typography variant="h6">{product.name}</Typography>
                    <Typography variant="h6" color="primary" sx={{ mt: 1 }}>
                      {product.price} ₽
                    </Typography>
                    <Typography color="text.secondary" sx={{ mt: 1 }}>
                      {product.description}
                    </Typography>
                  </Box>
                  <Box>
                    <IconButton onClick={() => handleEdit(product)} color="primary">
                      <Edit />
                    </IconButton>
                    <IconButton onClick={() => handleDelete(product.id)} color="error">
                      <Delete />
                    </IconButton>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          ))}
        </Box>

        <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
          <DialogTitle>{editingProduct ? 'Редактировать товар' : 'Добавить товар'}</DialogTitle>
          <DialogContent>
            <TextField
              autoFocus
              margin="dense"
              label="Название товара"
              fullWidth
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            />
            <TextField
              margin="dense"
              label="Цена"
              type="number"
              fullWidth
              value={formData.price}
              onChange={(e) => setFormData({ ...formData, price: Number(e.target.value) })}
            />
            <TextField
              margin="dense"
              label="Описание"
              fullWidth
              multiline
              rows={3}
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
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