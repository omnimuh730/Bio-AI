from sqlalchemy import Column, Integer, String, DateTime, Date, Float, JSON, Text
from sqlalchemy.orm import relationship
from .database import Base
import datetime


class User(Base):
    __tablename__ = "user"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class BioProfile(Base):
    __tablename__ = "bio_profile"
    user_id = Column(Integer, primary_key=True)
    height_cm = Column(Integer, nullable=True)
    weight_kg = Column(Float, nullable=True)
    birth_date = Column(Date, nullable=True)
    gender = Column(String(20), nullable=True)
    primary_goal = Column(String(50), nullable=True)
    dietary_preference = Column(String(50), nullable=True)
    allergies = Column(JSON, nullable=True)


class FoodLog(Base):
    __tablename__ = "food_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    log_time = Column(DateTime, default=datetime.datetime.utcnow)
    food_name = Column(String(200), nullable=False)
    calories = Column(Integer, nullable=True)
    protein_g = Column(Integer, nullable=True)
    carbs_g = Column(Integer, nullable=True)
    fats_g = Column(Integer, nullable=True)
    meta_data = Column(JSON, nullable=True)


class Leftover(Base):
    __tablename__ = "leftovers"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    recipe_name = Column(String(150), nullable=True)
    total_servings = Column(Float, nullable=True)
    remaining_servings = Column(Float, nullable=True)
    calories_per_serving = Column(Integer, nullable=True)
    macros_json = Column(JSON, nullable=True)


class DailyPlan(Base):
    __tablename__ = "daily_plan"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    date = Column(Date, nullable=False)
    target_calories = Column(Integer, nullable=True)
    target_protein = Column(Integer, nullable=True)
    next_meal_suggestion = Column(JSON, nullable=True)
