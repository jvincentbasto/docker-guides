import axios from "axios";
import { useState, useEffect } from "react";
import { Link } from "react-router-dom";

const Home = () => {
  const [anime, setAnime] = useState([]);

  useEffect(() => {
    axios
      .get(`${import.meta.env.VITE_API_URL}/api/anime`)
      .then((res) => {
        const data = Array.isArray(res?.data) ? res?.data : [];
        setAnime(data);
      })
      .catch((error) => {
        console.log(error?.message ?? "error");
      });
  }, []);

  return (
    <main className="container">
      <h1 className="heading">Explore</h1>
      <p className="sub_heading">List of anime to watch</p>

      <ul className="anime_list">
        {anime.length > 0
          ? anime.map((item) => (
              <li key={item._id} className="anime_card">
                <div className="anime_info">
                  <h4>{item.title}</h4>
                  <p>{item.description}</p>
                </div>

                <div className="anime_link">
                  <Link to={item.link} target="_blank" className="link">
                    Watch
                  </Link>
                </div>
              </li>
            ))
          : null}
      </ul>

      {anime.length === 0 && (
        <p className="no_result">Oops, No anime available</p>
      )}
    </main>
  );
};

export default Home;
