package com.example.products;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class ProductControllerTests {
    @Test
    void listsProducts() {
        ProductRepository repository = mock(ProductRepository.class);
        List<Product> expected = List.of(new Product("P1"));
        when(repository.findAll()).thenReturn(expected);

        assertEquals(expected, new ProductController(repository).list());
    }

    @Test
    void trimsAndCreatesProduct() {
        ProductRepository repository = mock(ProductRepository.class);
        when(repository.save(any(Product.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        new ProductController(repository)
                .create(new ProductController.CreateProductRequest("  P1  "));

        ArgumentCaptor<Product> saved = ArgumentCaptor.forClass(Product.class);
        verify(repository).save(saved.capture());
        assertEquals("P1", saved.getValue().getName());
    }
}
