import React from "react";
import SellerItems from "../../components/seller-items/SellerItems";
import MainLayout from "../../components/layouts/MainLayout";


export default function mylisteditems() {
  return (
    <MainLayout>
      <div className="container mylisteditems">
        <header>Your Songs</header>
      </div>
      <SellerItems />
    </MainLayout>
  );
}
